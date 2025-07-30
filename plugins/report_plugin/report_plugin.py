import os
from airflow.plugins_manager import AirflowPlugin
from flask import Blueprint
from flask_appbuilder.baseviews import BaseView as AppBuilderBaseView
from flask_appbuilder import expose
from airflow.models.dagrun import DagRun
from airflow.models.taskinstance import TaskInstance
from airflow.utils.session import provide_session
from airflow.configuration import conf

import ast
import re


# Define a Blueprint to find the template
bp = Blueprint(
    "report_plugin",
    __name__,
    template_folder="templates"  # Must match your folder structure
)

# Retrieve the Airflow base log folder from configuration or environment variables
BASE_LOG_FOLDER = conf.get("logging", "base_log_folder", fallback=os.getenv("AIRFLOW_BASE_LOG_FOLDER", "/opt/airflow/logs"))

def get_log_file_path(ti):
    run_id = ti.run_id
    try_number = ti.try_number
    task_id = ti.task_id
    dag_id = ti.dag_id

    # Check if it's a mapped task (Airflow sets map_index >= 0)
    map_index = getattr(ti, "map_index", -1)

    parts = [
        f"dag_id={dag_id}",
        f"run_id={run_id}",
        f"task_id={task_id}",
    ]

    if map_index != -1:
        parts.append(f"map_index={map_index}")

    parts.append(f"attempt={try_number}.log")

    return os.path.join(BASE_LOG_FOLDER, *parts)


# Define a View class that uses AppBuilderBaseView
class Reports(AppBuilderBaseView):
    default_view = "confluence_workflow"
    
    @expose("/confluence_workflow/")
    @provide_session
    def confluence_workflow(self, session=None):
        dag_id = os.getenv("REPORT_PLUGIN_DAG_ID", "swot_confluence_report_status_dag")

        detailed_module_data = None
        detailed_failure_data = None

        latest_run = (
            session.query(DagRun)
            .filter(DagRun.dag_id == dag_id)
            .order_by(DagRun.execution_date.desc())
            .first()
        )

        run_info = None
        tasks_logs = []

        if latest_run:
            run_info = {
                "run_id": latest_run.run_id,
                "state": latest_run.state,
                "execution_date": latest_run.execution_date,
                "start_date": latest_run.start_date,
                "end_date": latest_run.end_date,
            }

            task_instances = (
                session.query(TaskInstance)
                .filter(
                    TaskInstance.dag_id == dag_id,
                    TaskInstance.execution_date == latest_run.execution_date,
                )
                .all()
            )

            for ti in task_instances:
                log_text = ""
                try:
                    log_path = get_log_file_path(ti)
                    if log_path and os.path.exists(log_path):
                        with open(log_path, "r") as f:
                            log_text = f.read()
                    else:
                        log_text = f"No log file found at {log_path}"
                except Exception as e:
                    log_text = f"Error reading logs: {e}"

                tasks_logs.append({
                    "task_id": ti.task_id,
                    "state": ti.state,
                    "try_number": ti.try_number,
                    "log": log_text,
                })

                # Look for detailed module data only from the relevant task
                if ti.task_id == "report_status" and "Module data:" in log_text:
                    try:
                        match = re.search(r"\[report\] Module data: (.+)", log_text)
                        if match:
                            raw_dict = match.group(1)
                            parsed_data = ast.literal_eval(raw_dict)
                            detailed_module_data = parsed_data
                    except Exception as e:
                        detailed_module_data = {"error": f"Failed to parse module data: {e}"}

                # Look for detailed module data only from the relevant task
                if ti.task_id == "report_status" and "Failure data:" in log_text:
                    try:
                        match = re.search(r"\[report\] Failure data: (.+)", log_text)
                        if match:
                            raw_dict = match.group(1)
                            parsed_data = ast.literal_eval(raw_dict)
                            detailed_failure_data = parsed_data
                    except Exception as e:
                        detailed_failure_data = {"error": f"Failed to parse failure data: {e}"}

        return self.render_template("report_page.html", run_info=run_info, tasks_logs=tasks_logs, dag_id=dag_id, detailed_module_data=detailed_module_data, detailed_failure_data=detailed_failure_data)
    

# Register the plugin
class ReportPlugin(AirflowPlugin):
    name = "report_plugin"
    flask_blueprints = [bp]
    appbuilder_views = [
        {
            "name": "Confluence Workflow",
            "category": "Status Reports",
            "view": Reports(),
        }
    ]
