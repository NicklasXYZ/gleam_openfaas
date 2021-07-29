# Gleam OpenFaaS function templates

<p align="center">
  <img src="preview/logo.png" />
</p>

This repository contains [OpenFaaS](https://github.com/openfaas) function templates for writing serverless functions in the [Gleam](https://github.com/gleam-lang/gleam) programming language.


## Usage

1. Make sure OpenFaaS has been deployed to your Kubernetes cluster and the OpenFaaS CLI tool has been installed. See [here](https://github.com/NicklasXYZ/selfhosted-serverless) and [here](https://github.com/NicklasXYZ/selfhosted-serverless/blob/main/OpenFaaS.md) for a brief introduction on how to do this.

2. Download the Gleam function templates from this repo:

```
faas-cli template pull https://github.com/nicklasxyz/gleam_openfaas#main
```

3. Create a new function:

``` bash
faas-cli new --lang gleam test-function
```

Note: This essentially creates a usual Gleam project stucture, but with a pre-defined module name and files. The main functionality should be implemented in the files contained in the `test-function/function` directory. Extra dependencies should be added to the `rebar.config` file in the root of the `test-function` directory.

4. Add new functionality to the function that is going to be deployed and managed by OpenFaaS:

``` bash
vi test-function/function/src/function.gleam
# ... Extend or add whatever you want to the file
```

5. Make sure a valid container registry, to where functions can be pushed, has been defined in the `test-function.yml` file:

``` bash
vi test-function.yml
```

6. Finally, build, push and deploy the function:

```bash
# Authenticate with OpenFaaS (assuming kubectl is used with the k3s Kubernetes distribution):
PASSWORD=$(k3s kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
echo "OpenFaaS admin password: $PASSWORD"
faas-cli login --gateway http://localhost:31112 --password=$PASSWORD

# Build, push and deploy:
faas-cli build -f test-function.yml
faas-cli push -f test-function.yml
faas-cli deploy -f test-function.yml --gateway=http://localhost:31112

# ... or just:
faas-cli up -f test-function.yml --gateway=http://localhost:31112

# To remove function deployments run:
faas-cli remove -f test-function.yml --gateway=http://localhost:31112
```

7. Wait a few seconds, then we can invoke the function by sending a request through curl:

```bash
### Example GET request
curl -k \
    http://localhost:31112/function/test-function; \
    echo

# If nothing was changed in the 'test-function/function/src/function.gleam' file before
# deployment then we should just see the default response:
>> Hello from OpenFaaS!

### Example POST request:
curl -k \
    -d "{\"value\": {\"name\": \"YourNameHere\"}}" \
    -H "Content-Type: application/json" \
    -X POST http://localhost:31112/function/test-function; \
    echo

# If nothing was changed in the 'test-function/function/src/function.gleam' file before
# deployment then we should just see the default response:
>> {"int_field":42,"string_field":"Hello YourNameHere, from Gleam & OpenFaaS!"}
```

8. If we just want to check that the requests were handled properly then we can check the logs:

```bash
faas-cli logs test-function --gateway http://localhost:31112
```

The function can also be invoked through the public interface at `http://localhost:31112/ui/` using username `admin` and the previously defined password contained in environment variable `$PASSWORD`.


## Acknowledgements

The general webserver setup is taken from [this repository](https://github.com/gleam-lang/example-echo-server) by [gleam-lang](https://github.com/gleam-lang).
