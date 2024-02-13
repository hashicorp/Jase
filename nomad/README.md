#### Nomad 1.4 Demo

### Setup

Run `vagrant up` this will deploy a local VM and the 1.4 version of Nomad.


```
# Set the address (this is the default but you may have it set elsewhere)
export NOMAD_ADDR=http://172.31.23.85:4646
export NOMAD_TOKEN=a5a472af-fe85-2701-7708-d6e0e0622f15

```

### Lets deploy a load balancer

```
nomad job run traefik.nomad
```

Take a look at the dashboard
```
open http://localhost:8080
```

# Do we have any variables?

```
nomad var list
```
### Deploy some secure variables

Browse to the new variables page UI at `http://localhost:4646/ui/variables`

 We can also do this via the CLI

 Lets set some, scoped to the job

```
nomad var put nomad/jobs/mysql-server \
    MYSQL_USER=wordpress \
    MYSQL_PASSWORD=highlysecurepassword \
    MYSQL_DATABASE=wordpress \
    MYSQL_RANDOM_ROOT_PASSWORD=1
```
# And run the mysql job

```
nomad job run jobs/mysql.nomad
```

We can now exec into the database via the UI.

### Time for something to use our database

```
nomad var put nomad/jobs/wordpress \
    WORDPRESS_DB_NAME=wordpress \
    WORDPRESS_DB_USER=wordpress \
    WORDPRESS_DB_PASSWORD=highlysecurepassword

nomad var list
```

```
nomad job run jobs/wordpress.nomad
```



We can now use a static port to reach our dynamic services. 

`open localhost/`



