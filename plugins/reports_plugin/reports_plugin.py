import os
from airflow.plugins_manager import AirflowPlugin
from flask import Blueprint
from flask_appbuilder.baseviews import BaseView as AppBuilderBaseView
from flask_appbuilder import expose
from airflow.utils.session import provide_session

import boto3
from report import aggregate_run_data

AWS_ACCOUNT_ID_SIT = os.getenv("AWS_ACCOUNT_ID_SIT")
STATE_MACHINE_ARN = f"arn:aws:states:us-west-2:{AWS_ACCOUNT_ID_SIT}:stateMachine:svc-confluence-sit-workflow"


# Define a Blueprint to find the template
bp = Blueprint(
    "reports_plugin",
    __name__,
    template_folder="templates"  # Must match your folder structure
)

def fetch_last_execution(state_machine_arn: str):
    client = boto3.client("stepfunctions", region_name="us-west-2")
    # Get the most recent execution regardless of status
    response = client.list_executions(
        stateMachineArn=state_machine_arn,
        maxResults=1
    )
    if response["executions"]:
        return response["executions"][0]["executionArn"]
    return None

def report_status(execution_arn: str):
        client = boto3.client("stepfunctions", region_name="us-west-2")
        name = execution_arn.split(":")[-1]

        print(f"[report] Execution: {execution_arn}")
        temporal_range = None

        try:
            execution = client.describe_execution(executionArn=execution_arn)
            status = execution["status"]
            print(f"[report] Execution: {execution_arn} | Status: {status}")

            module_data, failure_data = aggregate_run_data(execution_arn, name, temporal_range)
            print(f"[report] Module data: {module_data}")
            print(f"[report] Failure data: {failure_data}")

            return module_data, failure_data
        except Exception as e:
            print(f"[report] Error analyzing {execution_arn}: {e}")


# Define a View class that uses AppBuilderBaseView
class Reports(AppBuilderBaseView):
    default_view = "confluence_workflow_new"
    
    @expose("/confluence_workflow_new/")
    @provide_session
    def confluence_workflow_new(self, session=None):

        detailed_module_data = None
        detailed_failure_data = None

        # Task chaining
        execution_arn = fetch_last_execution(STATE_MACHINE_ARN)

        if execution_arn:
            module_data, failure_data = report_status(execution_arn=execution_arn)

            detailed_module_data = module_data
            detailed_failure_data = failure_data

        return self.render_template("reports_page.html", detailed_module_data=detailed_module_data, detailed_failure_data=detailed_failure_data)


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
