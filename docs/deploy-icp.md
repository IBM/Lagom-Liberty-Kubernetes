# Deploy the Lagom Message Hub Liberty integration example with IBM Cloud Private

Lagom has the flexibility to be deployed to a variety of production environments. For detailed information, see the documentation on [Running Lagom in Production](https://www.lagomframework.com/documentation/1.3.x/java/ProductionOverview.html).

This guide demonstrates how to deploy the Lagom service to a Kubernetes cluster running in the cloud using [IBM Cloud Private](https://www.ibm.com/cloud-computing/products/ibm-cloud-private/)**(ICP)**. 

## Table of Contents

1.  [Install IBM Cloud Private](#install-ibm-cloud-private)
2.  [Build the Docker image](#build-the-docker-image)
3.  [Deploy Cassandra to ICP](#deploy-cassandra-to-icp)
4.  [Deploy the Lagom service to ICP](#deploy-the-lagom-service-to-icp)
5.  [Test the Lagom service in ICP](#test-the-lagom-service-in-icp)
    1.  [Connect to the Lagom message stream](#connect-to-the-lagom-message-stream)
    2.  [Test producing a message from the Liberty sample application](#test-producing-a-message-from-the-liberty-sample-application)
    3.  [Test producing a message from the Lagom service](#test-producing-a-message-from-the-lagom-service)
6.  [Delete the Lagom service from ICP](#delete-the-lagom-service-from-icp)
7.  [Next steps](#next-steps)


**Before performing the following steps, follow the instructions in**[`README.md`](../README.md).

## Install IBM Cloud Private

Follow the [instruction](https://github.com/IBM/deploy-ibm-cloud-private)
Make sure in the `Accessing IBM Cloud Private` section, change the cluster name from `mycluster.icp` to `lagom-test`.

## Build the Docker image

If you have IBM Cloud Container Registry set up as described in the other [document](deploy-with-bluemix.md#create-a-container-registry-namespace-in-ibm-cloud), please follow the steps:

1.  Build the Docker image locally:
    ```
    mvn clean package docker:build
    ```
2.  Upload it to your private registry:
    ```
    docker tag lagom/message-hub-liberty-integration-impl registry.ng.bluemix.net/<registry-namespace>/lagom/message-hub-liberty-integration-impl
    docker push registry.ng.bluemix.net/<registry-namespace>/lagom/message-hub-liberty-integration-impl
    ```
Or, you can use a public registry such as Docker Store. But you will have to change the tags in above commands to reflect the registry. Plus you will have to change all the kubernetes deployment files to reflect the path of the images.

## Deploy Cassandra to ICP

1.  If you are using an existing Kubernetes cluster, check if the Cassandra service has already been deployed:
    ```
    kubectl get service cassandra
    ```
    If this prints "`services "cassandra" not found`" then proceed. If there is an existing service, you can skip this section and move on to [Deploy the Lagom service to IBM Cloud](#deploy-the-lagom-service-to-bluemix).
2.  Create the Cassandra pod in Kubernetes:
    ```
    kubectl create -f kubernetes/cassandra
    ```
3.  Wait for the Cassandra pod to become available:
    ```
    kubectl get -w pod cassandra-0
    ```
    This will print the current state of the Cassandra pod and update on changes:
    ```
    NAME          READY     STATUS              RESTARTS   AGE
    cassandra-0   0/1       ContainerCreating   0          10s
    cassandra-0   0/1       Running   0         1m
    cassandra-0   1/1       Running   0         2m
    ```
    Your output might vary, but once you see a line with "1/1" and "Running", you can press control-C to exit and continue to the next step.
4.  Verify the Cassandra deployment:
    ```
    kubectl exec cassandra-0 -- nodetool status
    ```
    This runs a Cassandra status check, and should print output like the following:
    ```
    Datacenter: DC1-K8Demo
    ======================
    Status=Up/Down
    |/ State=Normal/Leaving/Joining/Moving
    --  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
    UN  172.17.0.4  99.47 KiB  32           100.0%            f4d1adaa-89d7-4726-8081-f7a15be676ee  Rack1-K8Demo
    ```

## Deploy the Lagom service to ICP

1.  Create the Lagom service pod in Kubernetes:
    ```
    kubectl create -f kubernetes/lagom-message-hub-liberty-integration/bluemix
    ```
2.  Wait for the Lagom service pod to become available:
    ```
    kubectl get -w pod lagom-message-hub-liberty-integration-0
    ```
    This will print the current state of the Lagom service pod and update on changes:
    ```
    NAME                                      READY     STATUS    RESTARTS   AGE
    lagom-message-hub-liberty-integration-0   1/1       Running   0          14s
    ```
    As above, once you see a line with "1/1" and "Running", you can press control-C to exit and continue to the next step.
3.  Make the service available to your local system:
    ```
    kubectl port-forward lagom-message-hub-liberty-integration-0 9000:9000
    ```
    This will print this output:
    ```
    Forwarding from 127.0.0.1:9000 -> 9000
    Forwarding from [::1]:9000 -> 9000
    ```
    At this point, the service is ready for testing.

## Test the Lagom service

You can test the running Lagom service by following these three steps:

1.  [Connect to the Lagom message stream](#connect-to-the-lagom-message-stream)
2.  [Test producing a message from the Liberty sample application](#test-producing-a-message-from-the-liberty-sample-application)
3.  [Test producing a message from the Lagom service](#test-producing-a-message-from-the-lagom-service)

### Connect to the Lagom message stream

From a WebSocket client, you can monitor the stream of messages that the Lagom service is consuming from Message Hub, and send messages to Lagom to produce to Message Hub, by connecting to the service URI as follows:

1.  Go to https://www.websocket.org/echo.html.
2.  In the **Location:** field, enter "`ws://localhost:9000/messages`".
3.  Click **Connect**.

### Test producing a message from the Liberty sample application

1.  In another browser window or tab, navigate to the URL of the Liberty application deployed to IBM Cloud, and click the **Produce a Message** button.
2.  Return to the WebSocket Echo Test tab in your browser.
3.  Within a few seconds, you should see the message produced from the Liberty application in the **Log** panel.

### Test producing a message from the Lagom service

1.  In the WebSocket Echo Test tab in your browser, enter a message into the **Message** field and click the **Send** button.
2.  Within a few seconds, you should see the message you sent repeated in the **Log** panel.
3.  Return to the Liberty application tab in your browser, and reload the page.
4.  You should see the message you sent in the list of **Already consumed messages**.

## Delete the Lagom service from ICP

When you are finished testing the service in ICP, you can delete all the resources from the Kubernetes cluster.

1.  Run `kubectl delete all --all` to remove all the resources in current name space
2.  (Optional) Remove the ICP installation

## Next steps

From here, you can try another option for running the example:

- [Run in development mode](run-in-development-mode.md)
- [Deploy in IBM Cloud Container Service](deploy-with-bluemix.md)

