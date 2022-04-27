# Get IP of node
```bash
terraform output node_1_internal_ip
```

```bash
bin/setup
aws-vault exec admin -- \
bin/create
bin/ip node_1
terraform output
bin/ssh node_1
bin/playbook node_1 volume
bin/node-1
bin/ssh node_1 df -h
bin/playbook node_1 es-master
bin/playbook node_2 es-data
bin/logs node_1
bin/tunnel node_1
aws-vault exec admin -- bin/apply
aws-vault exec admin -- \
bin/node3 & bin/node4 &
aws-vault exec admin -- bin/destroy
aws-vault exec admin -- bin/destroy-target aws_instance.node_4
aws-vault exec admin --
bin/start node_1
bin/nodes
aws-vault exec admin --
bin/stop node_1

bin/allocation-enable
bin/allocation-disable
bin/shards | less

bin/nodes
bin/stats id1,id2...
bin/stats

bin/indexes
bin/replicas "sessionevent-*" 0

./bin/ssh node_1 curl -s -XGET 'localhost:9200/profile/_mapping?pretty' | less
./bin/ssh node_1 curl -s -XGET 'localhost:9200/_cat/nodes?v'
./bin/ssh node_1 curl -s -XGET 'localhost:9200/_cat/shards?v'
./bin/ssh node_1 curl -s -XDELETE 'localhost:9200/profile,device,visitor,anon-*,session-*,sessionevent-*,event-*,chatmessage-*?pretty'
./bin/ssh node_1 'sudo rm -rf /mnt/data/nodes'
bin/ssh node_1 'sudo systemctl start elasticsearch'


# https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-metricbeat.html
PUT _cluster/settings
{
  "persistent": {
    "xpack.monitoring.collection.enabled": true
  }
}

# http://localhost:5604/app/monitoring
```

# Bring up new node
```bash
id1=9
id2=10
bin/new-node "$id1" "$id2"
aws-vault exec admin -- bin/apply
# wait for boot, then:
"bin/node-$id2"
```

# Remove node
```bash
id="1"
bin/ssh "node_$id" "
  sudo systemctl stop elasticsearch
"
git rm "bin/node-$id"
git rm "node-$id.tf"
aws-vault exec admin -- bin/apply
```

# Exclude
```bash
# get node ids
bin/nodes
bin/exclude id1,id2...
# e.g:
bin/exclude 'sa7Nkzp2QoOj5Iy0Cp9ceg,paoW2-3XTfaLFLRwwJHgAA,dO6y0kfRQ8yf1O7VL-kl2A,ReldjZqNSVCibY3MEXYVkA,BxI0ghsdRqSK3BbGie9pkA'
bin/shards | less
bin/allocation
# reset
bin/exclude
```

# Expand volume
```bash
# e.g. expand node_1
bin/ssh node_1 df -h
# modify volume in aws console
open "https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=es-7"
# expand volume
bin/playbook node_1 expand-volume
# update ebs size in node-1.tf
vim node-1.tf
# check expanded
bin/ssh node_1 df -h
```

# Run playbook
```bash
bin/playbook <node> <playbook> [ playbook args ]
```
Example:
```bash
bin/playbook node_5 authorised-keys --private-key "$(pwd)/key"
```

# Kibana
⚠️ This makes es-7 available on localhost. We reduce risk
by using a non-standard port `9451` (the default is `9200`) but
be mindful that anything that talks to `9451` talks to real ES.

Start the tunnel:
```bash
bin/tunnel
```
Start Kibana:
```bash
bin/kibana
```
Stop kibana
```bash
docker-compose stop kibana && docker-compose rm -f kibana
```
http://localhost:5601/app/dev_tools#/console

http://localhost:5601/app/monitoring#/overview

# Master node configuration
https://discuss.elastic.co/t/number-of-master-nodes-for-a-multi-node-cluster/223310/2

> ...this is the rule to set the minimum master node in a cluster. Your node should be in odd number like 3,5 etc.

> Three dedicated master nodes, the recommended number, provides two backup nodes in the event of a master node failure and the necessary quorum (2) to elect a new master. Four dedicated master nodes are no better than three and can cause issues if you use multiple Availability Zones.

https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-dedicatedmasternodes.html

# Logs
```bash
# tail logs on given node
bin/logs node_1
# tail logs on all nodes
bin/logs-all
# search logs on given node
bin/ssh node_1 sudo bash -c \'zgrep 120570540 /var/log/elasticsearch/*.log.gz\'
```

# slowlog
```bash
bin/set-slowlog <index> <threshold>
```
Example:
```bash
bin/set-slowlog profile 200ms
```
Read slowlog:
```bash
bin/ssh node_1 -t sudo less /var/log/elasticsearch/es-7-1_index_search_slowlog.log
```

# Set replicas
⚠️ Before increasing replicas, check there is enough free disk
space on the nodes http://localhost:5601/app/monitoring#/elasticsearch/nodes

(see kibana section)
## Usage
```bash
bin/replicas <indexes> <num>
```
## Examples
1 replica for all `sessionevent` indexes.
```bash
bin/replicas 'sessionevent-*' 1
```
1 replica for `device` and `profile` indexes:
```bash
bin/replicas 'device,profile' 1
```
