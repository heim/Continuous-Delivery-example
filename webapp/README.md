Usage
=====

Alternative 1:
--------------
* Build it: <code>mvn clean install</code>
* Unzip it: <code>unzip target/webapp-*.zip</code>
* Run it: <code>target/webapp-*/bin/webapp</code>

Alternative 2:
--------------
* Build it: <code>mvn clean install</code>
* Run it: <code>mvn exec:java</code>

Not an alternative:
-------------------
* We don't do jetty:run. Use <code>mvn exec:java</code> instead. We want to run the same code every time!

Deployment
==========

Alternative 1:
--------------
* Use ../scripts/push_deploy.sh

Alternative 2:
--------------
1. <code>mvn clean install -Dpush-deploy</code>

2. <code>mvn clean -Dpull-deploy</code>

3. <code>mvn clean -Drollback</code>
