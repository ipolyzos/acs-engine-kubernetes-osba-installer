# Open Service Broker for Azure (OSBA) on ACS-Engine Kubernetes deployment installer

[Open Service Broker for Azure (OSBA)](https://osba.sh/) on [ACS-Engine Kubernetes deployment installer](https://github.com/Azure/acs-engine) is a bash script to automate deployment of OSBA on a ACS-Engine deployed Kubernetes cluster.

## Prerequisites

- [Kubectl](https://github.com/kubernetes/kubectl) >= 1.9
- [Helm](https://github.com/kubernetes/helm) v2.8.1

**NOTE:**

 - The script is able to manage _(i.e download and install)_ any dependencies and apropriate versions as required.
 - Supported operating systems include [Linux](https://en.wikipedia.org/wiki/Linux) and [MacOS](https://en.wikipedia.org/wiki/Macintosh_operating_systems).

## Installation

Installation of the OSBA installer script only require to download in your machine.

## Usage

The script expects you to have logged in your Azure account and set the right subscription before run.

Usage of the script is descrited help the page i.e.

```
osba.sh : OSBA Installer for ACS-Engine Kubernetes deployments.
Usage: ./osba.sh [options]
options:
    -o, --osba-version               Set the version of OSBA helm to use.
    -s, --service-principal-prefix   Set a prefix for service principal's name.
    -r, --remove                     Remove OSBA installation.
    -h, --help                       Display this help message.
```

## Contributing

 See the [contribution guidelines](CONTRIBUTING.md).

## History

2018-06-27 - Initial commit

## References

 - [Service Catalog](https://github.com/kubernetes-incubator/service-catalog)
 - [Service Catalog Installation](https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/install.md)
 - [Service Catalog - Helm repository setup](https://github.com/kubernetes-incubator/service-catalog/blob/master/docs/install.md#helm-repository-setup)
 - [Open Service Broker for Azure](https://osba.sh/)
 - [The Open Service Broker API Server for Azure Services]( https://github.com/Azure/open-service-broker-azure)
 - [OSBA FAQ]( https://github.com/Azure/open-service-broker-azure/blob/master/docs/faq.md)
 - [Open Service Broker for Azure Samples](https://github.com/neilpeterson/open-service-broker-azure-samples)
 - [OSBA Versions and Module Stability](https://github.com/Azure/open-service-broker-azure/blob/master/docs/stability.md)
 - [Azure Modules Documentation (incl experimental)](https://github.com/Azure/open-service-broker-azure/tree/master/docs/modules)
 - [Helm charts for use with Kubernetes service-catalog](https://github.com/Azure/helm-charts/)
 - [Creating a new chart](https://github.com/Azure/helm-charts#creating-a-new-chart)
 - [Open Service Broker for MongoDB on Azure provided by CosmosDB](https://github.com/neilpeterson/open-service-broker-azure-samples/tree/master/osba-cosmosdb-mongodb-sample)

## License
```
Copyright (c) 2018 Ioannis Polyzos

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```