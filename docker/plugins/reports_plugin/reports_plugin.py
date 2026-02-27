import os
import sys
from airflow.plugins_manager import AirflowPlugin
from flask import Blueprint
from flask_appbuilder.baseviews import BaseView as AppBuilderBaseView
from flask_appbuilder import expose
from airflow.utils.session import provide_session

import boto3


# Ensure the current directory is on sys.path
PLUGIN_DIR = os.path.dirname(os.path.abspath(__file__))
if PLUGIN_DIR not in sys.path:
    sys.path.insert(0, PLUGIN_DIR)

from report import aggregate_run_data

AWS_ACCOUNT_ID_SIT = os.getenv("AWS_ACCOUNT_ID_SIT")
STATE_MACHINE_ARN = f"arn:aws:states:us-west-2:{AWS_ACCOUNT_ID_SIT}:stateMachine:svc-confluence-sit-workflow"


# Define a Blueprint to find the template
bp = Blueprint(
    "reports_plugin",
    __name__,
    template_folder="templates"  # Must match your folder structure
)

def fetch_last_executions(state_machine_arn: str, max_results: int = 15):
    client = boto3.client("stepfunctions", region_name="us-west-2")
    # Get the most recent executions
    response = client.list_executions(
        stateMachineArn=state_machine_arn,
        maxResults=max_results
    )
    return response["executions"] if response["executions"] else []

def report_status(execution_arn: str):
        client = boto3.client("stepfunctions", region_name="us-west-2")
        name = execution_arn.split(":")[-1]

        print(f"[report] Execution: {execution_arn}")
        temporal_range = None

        try:
            execution = client.describe_execution(executionArn=execution_arn)
            status = execution["status"]
            print(f"[report] Execution: {execution_arn} | Status: {status}")

            # Get the state input from the execution
            state_input = execution.get("input", "{}")
            print(f"[report] State input: {state_input}")

            module_data, failure_data = aggregate_run_data(execution_arn, name, temporal_range)
            print(f"[report] Module data: {module_data}")
            print(f"[report] Failure data: {failure_data}")

            return module_data, failure_data, state_input, status
        except Exception as e:
            print(f"[report] Error analyzing {execution_arn}: {e}")


# Define a View class that uses AppBuilderBaseView
class Reports(AppBuilderBaseView):
    default_view = "confluence_workflow"
    
    @expose("/confluence_workflow/")
    @provide_session
    def confluence_workflow(self, session=None):
        from flask import request, jsonify
        
        # Check if this is an AJAX request for loading execution details
        execution_arn = request.args.get('execution_arn')
        if execution_arn:
            try:
                module_data, failure_data, state_input, status = report_status(execution_arn=execution_arn)
                return jsonify({
                    "module_data": module_data,
                    "failure_data": failure_data,
                    "state_input": state_input,
                    "status": status
                })
            except Exception as e:
                return jsonify({"error": str(e)}), 500
        
        # Regular page load - fetch the last 10 executions for the dropdown
        executions = fetch_last_executions(STATE_MACHINE_ARN, 15)
        
        return self.render_template("reports_page.html", executions=executions)


# Register the plugin
class ReportsPlugin(AirflowPlugin):
    name = "reports_plugin"
    flask_blueprints = [bp]
    appbuilder_views = [
        {
            "name": "Confluence Workflow",
            "category": "Status Reports",
            "view": Reports(),
        }
    ]
