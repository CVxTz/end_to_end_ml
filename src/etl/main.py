import os
from datetime import date

import functions_framework
import google.cloud.logging
import pandas as pd
from dateutil.relativedelta import relativedelta
from requests import get  # to make GET request

logging_client = google.cloud.logging.Client()
logging_client.setup_logging()


def download(url, file_name):
    # open in binary mode
    with open(file_name, "wb") as file:
        # get request
        response = get(url)
        # write to file
        file.write(response.content)


TABLE = os.environ["TABLE"]
GCP_PROJECT = os.environ["GCP_PROJECT"]


@functions_framework.http
def download_parquet(request):
    data = request.get_json() if request.get_json() else {}

    year = data.get("year", (date.today() - relativedelta(months=2)).strftime("%Y"))
    month = data.get("month", (date.today() - relativedelta(months=2)).strftime("%m"))

    query_url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{year}-{month}.parquet"

    file_name = f"yellow_tripdata_{year}-{month}.parquet"
    file_path = f"/tmp/{file_name}"

    download(query_url, file_path)

    df = pd.read_parquet(file_path).head(10)  # TODO remove head

    df.to_gbq(destination_table=TABLE, project_id=GCP_PROJECT, if_exists="append")

    os.remove(file_path)

    return "", 200
