# TODO
- [ ] Ansible /dev/null problem 

Bootstrap [Piku](https://github.com/piku/piku) onto a fresh Ubuntu server. Piku lets you do `git push` deploys to your own server.

The easiest way to get started is using the get script:

```
ssh root@YOUR-FRESH-UBUNTU-SERVER
curl https://raw.githubusercontent.com/angordeyev/piku-bootstrap/master/install.sh | sh
```

**Warning**: Please use a fresh Ubuntu server as this script will modify system level settings.
See [piku.yml](./playbooks/piku.yml) to see what will be changed.

The first time it is run `piku-bootstrap` will install itself into `/root/.piku-bootstrap` on the server and set up a virtualenv there with the dependencies it requires. It will only need to do this once.

The script will display a usage message and you can then bootstrap your server:

```shell
./piku-bootstrap install
```

Once you're done head over to the [Piku documentation](https://github.com/piku/piku/#using-piku) to see how to deploy your first app.

### Installing other dependencies

`piku-bootstrap` uses Ansible internally and it comes with some extra built-in playbooks which you can use to bootstrap common components onto your `piku` server.

Use `piku-bootstrap list-playbooks` to show a list of built-in playbooks, and then to install one add it as an argument to the bootstrap command.

For example, to deploy `postgres` onto your server:

```shell
piku-bootstrap postgres.yml
```

You can also use `piku-bootstrap` to run your own Ansible playbooks like this:

```shell
piku-bootstrap ./myplaybook.yml
```
