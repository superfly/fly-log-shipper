# fly-log-shipper

Ship logs from fly to other providers using [NATS](https://docs.nats.io/) and [Vector](https://vector.dev/)

Here we have some vector configs and a nats client (\`fly-logs\`), along side a wrapper script to run it all, that will subscribe to a log stream of your organisations logs, and ship it to various providers.

# CO2-specific Configuration

## New Fly Logging App

First, you will need to create a new `.toml` file for storing basic
configuration for this Fly app. Cloning an existing file is the easiest path
forward: `cp dev-rails-fly.toml my-new-fly-app.toml`.

Now open the new `.toml` file to configure it for a new deployment. First, the
value for `app` must be unique and match the name you'd like for the app.
Second, edit the following values under the `[env]` section:
| ENV Variable          | Description                                                                                                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PAPERTRAIL_ENDPOINT` | The port-based destination created via PaperTrail's "Add System" button on their [dashboard](https://papertrailapp.com/dashboard)                    |
| `SUBJECT`             | Used to filter log messages to specific systems against Fly's [subject hierarchies](https://docs.nats.io/nats-concepts/subjects#subject-hierarchies) |

Now we need to deploy the application using our new `.toml` file. To do this
we'll need the "app" name defined at the top of the `.toml` file. Now we can
create the app with the command: `flyctl apps create --name A_NAME_GOES_HERE`.

The next task is to set an access token for `flyctl` to make use of. You can
create a new access token from
[this](https://fly.io/user/personal_access_tokens) page. Once the token is
generated copy it and then set it with this command:  
`flyctl secrets set ACCESS_TOKEN="MY_SECRET_ACCESS_TOKEN"`.

Finally, we can deploy the app with `flyctl deploy -c my-new-fly-app.toml`. In
this case, the `-c` flag is indicating a specific `.toml` file to use for the
deployment. Additional info on the `-c` flag can be found at the
[fly docs](https://fly.io/docs/reference/configuration/#the-app-name).

## Redeploy Existing Fly Logging App

Redeploying an existing app should be as simple as identifying the correct
`.toml` file and running: `flyctl deploy -c relevantfly-app.toml`.

# Generic Configuration

**The documentation below is from the original repository and is left as-is to
provide additional information.**

Create a new Fly app based on this Dockerfile and configure using the following secrets:

## fly-logs configuration

| Secret         | Description                                                                                                      |
| -------------- | ---------------------------------------------------------------------------------------------------------------- |
| `ORG`          | Organisation slug                                                                                                |
| `ACCESS_TOKEN` | Fly personal access token                                                                                        |
| `SUBJECT`        | Subject to subscribe to. See [[NATS]] below (defaults to `logs.>`)                                             |
| `QUEUE`        | Arbitrary queue name if you want to run multiple log processes for HA and avoid duplicate messages being shipped |

## Provider configuration

### AWS S3

| Secret                  | Description                                  |
| ----------------------- | -------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | AWS Access key with access to the log bucket |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key                        |
| `AWS_BUCKET`            | AWS S3 bucket to store logs in               |
| `AWS_REGION`            | Region for the bucket                        |

### Datadog

| Secret            | Description                      |
| ----------------- | -------------------------------- |
| `DATADOG_API_KEY` | API key for your Datadog account |

### Honeycomb

| Secret              | Description       |
| ------------------- | ----------------- |
| `HONEYCOMB_API_KEY` | Honeycomb API key |
| `HONEYCOMB_DATASET` | Honeycomb dataset |

### Humio

| Secret        | Description |
| ------------- | ----------- |
| `HUMIO_TOKEN` | Humio token |

### Logdna

| Secret           | Description    |
| ---------------- | -------------- |
| `LOGDNA_API_KEY` | LogDNA API key |

### Logflare

| Secret                  | Description                                             |
| ----------------------- | ------------------------------------------------------- |
| `LOGFLARE_API_KEY`      | Logflare ingest API key                                 |
| `LOGFLARE_SOURCE_TOKEN` | Logflare source token (uuid on your Logflare dashboard) |

### Logtail

| Secret          | Description        |
| --------------- | ------------------ |
| `LOGTAIL_TOKEN` | Logtail auth token |

### Loki

| Secret          | Description   |
| --------------- | ------------- |
| `LOKI_URL`      | Loki Endpoint |
| `LOKI_USERNAME` | Loki Username |
| `LOKI_PASSWORD` | Loki Password |

### New Relic
One of these is required for New Relic logs. New Relic recommend the license key be used (ref: https://docs.newrelic.com/docs/logs/enable-log-management-new-relic/enable-log-monitoring-new-relic/vector-output-sink-log-forwarding/)

| Secret                  | Description                      |
| ----------------------- | -------------------------------- |
| `NEW_RELIC_INSERT_KEY`  | (optional) New Relic Insert key  |
| `NEW_RELIC_LICENSE_KEY` | (optional) New Relic License key |

### Papertrail

| Secret                | Description         |
| --------------------- | ------------------- |
| `PAPERTRAIL_ENDPOINT` | Papertrail endpoint |

### Sematext

| Secret            | Description     |
| ----------------- | --------------- |
| `SEMATEXT_REGION` | Sematext region |
| `SEMATEXT_TOKEN`  | Sematext token  |


### Uptrace

| Secret            | Description        |
| ----------------- | ------------------ |
| `UPTRACE_API_KEY` | Uptrace API key    |
| `UPTRACE_PROJECT` | Uptrace project ID |

### EraSearch

| Secret                  | Description                                  |
| ----------------------- | -------------------------------------------- |
| `ERASEARCH_URL`         | EraSearch Endpoint                           |   
| `ERASEARCH_AUTH`        | EraSearch User                               |
| `ERASEARCH_INDEX`       | EraSearch Index you want to use              |

---

# NATS

The log stream is provided through the [NATS protocol](https://docs.nats.io/nats-protocol/nats-protocol) and is limited to subscriptions to logs in your organisations. The `fly-logs` app is simply a Go NATS client that takes some Fly specific environment variables to connect to the stream, but any NATS client can connect to `fdaa::3` on port `4223` in a Fly vm, with an organisation slug as the username and a Fly Personal Access Token as the password.

The subject schema is `logs.<app_name>.<region>.<instance_id>` and the standard [NATS wildcards](https://docs.nats.io/nats-concepts/subjects#wildcards) can be used. In this app, the `SUBJECT` secret can be used to set the subject and limit the scope of the logs streamed.

If you would like to run multiple vm's for high availability, the NATS endpoint supports [subscription queues](https://docs.nats.io/nats-concepts/queue) to ensure messages are only sent to one subscriber of the named queue. The `QUEUE` secret can be set to configure a queue name for the client.

---

# Vector

The `fly-logs` application sends logs to a unix socket which is created by Vector. This processes the log lines and sends them to various providers. The config is generated from a shell wrapper script which uses conditionals on environment variables to decide which Vector sinks to configure in the final config.
