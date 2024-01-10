# k8s-certman-pg

# TLS Connection Setup for PostgreSQL in Kubernetes

This guide provides step-by-step instructions on setting up a TLS connection between a PostgreSQL server deployed within a local Kubernetes cluster and a psql client running externally, leveraging cert-manager.

## Steps:

### Step 1: Install the necessary tools
```
./install_tools.sh
```

### Step 2: Deploy the cert-manager, Issuers, and Postgres
```
./deploy.sh
```
If everything runs smoothly, the following resources should be created:
```
issuer.cert-manager.io/selfsigned created
certificate.cert-manager.io/root-ca-cert created
issuer.cert-manager.io/root-ca created
deployment.apps/postgresql created
service/postgresql-service created
configmap/postgresql-conf created
certificate.cert-manager.io/postgresql-tls created
```

### Step 3: Check node, deployment, service, issuer, certificate, and pod before verifying the TLS connection
```
kubectl -n sandbox get node
kubectl -n sandbox get deployment
kubectl -n sandbox get service
kubectl -n sandbox get issuer
kubectl -n sandbox get certificate
kubectl -n sandbox get secret
kubectl -n sandbox get pods
... 
```

### Step 4: Get the trust anchor ca.crt and save it to a file
```
kubectl -n sandbox get secret postgresql-tls-secret -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
```

### Step 5: Verify local Kubernetes cluster IP and update psql commands correspondingly if not the same
```
minikube ip
192.168.49.2
```

### Step 6: Verify TLS connection using psql and check settings
```
psql "sslmode=verify-full sslrootcert=ca.crt dbname=postgres user=postgres hostaddr=192.168.49.2 port=32345 host=postgresql-service"
psql (17devel, server 16.1 (Debian 16.1-1.pgdg120+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

postgres=# SELECT name, setting, short_desc FROM pg_settings WHERE name LIKE 'ssl%';
                  name                  |         setting          |                               short_desc                                
----------------------------------------+--------------------------+-------------------------------------------------------------------------
 ssl                                    | on                       | Enables SSL connections.
 ssl_ca_file                            | /tls/ca.crt              | Location of the SSL certificate authority file.
 ssl_cert_file                          | /tls/tls.crt             | Location of the SSL server certificate file.
...
 ssl_key_file                           | /tls/tls.key             | Location of the SSL server private key file.
...

(15 rows)

postgres=# SELECT datname, usename, ssl, client_addr, application_name FROM pg_stat_ssl JOIN pg_stat_activity ON pg_stat_ssl.pid = pg_stat_activity.pid;
 datname  | usename  | ssl | client_addr | application_name 
----------+----------+-----+-------------+------------------
 postgres | postgres | t   | 10.244.0.1  | psql
(1 row)

postgres=# 
```

### Step 7: Log into the Postgres pod and verify more...
```
kubectl -n sandbox exec -it $(kubectl -n sandbox get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}') -- bash
root@postgresql-64b859df66-l4lw5:/# apt update && apt install -y procps iputils-ping net-tools

root@postgresql-64b859df66-l4lw5:/# ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
postgres       1       0  0 02:20 ?        00:00:00 postgres -c config_file=/conf/postgresql.conf -c hba_file=/conf/pg_hba.conf
postgres      60       1  0 02:20 ?        00:00:00 postgres: checkpointer 
postgres      61       1  0 02:20 ?        00:00:00 postgres: background writer 
postgres      63       1  0 02:20 ?        00:00:00 postgres: walwriter 
postgres      64       1  0 02:20 ?        00:00:00 postgres: autovacuum launcher 
postgres      65       1  0 02:20 ?        00:00:00 postgres: logical replication launcher 
postgres      80       1  0 02:27 ?        00:00:00 postgres: postgres postgres 10.244.0.1(48594) idle

root@postgresql-64b859df66-l4lw5:/# psql -d postgres -U postgres 
psql (16.1 (Debian 16.1-1.pgdg120+1))
Type "help" for help.

postgres=#
```

Feel free to make any further adjustments or let me know if you need more modifications!

