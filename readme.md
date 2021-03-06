# Script for managing Antidote

Create a datacenter:

	antidote-connect --createDc server1:8087 antidote@server2 antidote@server3

Join several datacenters (giving one server address per datacenter):

	antidote-connect --connectDcs server1:8087 server4:8087

## Compile

The Makefile can be used to build a Docker image containing the script.

	make deps
	make


## Example Docker-compose file

Adapted from https://github.com/AntidoteDB/docker-antidote/tree/master/compose-files

	version: '3.4'

	# Specify feature configuration for all nodes at once
	# See AntidoteDB documentation on how to configure these features
	x-antidote-features:
	&default-features
	ANTIDOTE_TXN_CERT: "true"
	ANTIDOTE_TXN_PROT: "clocksi"
	ANTIDOTE_RECOVER_FROM_LOG: "true"
	ANTIDOTE_META_DATA_ON_START: "true"
	ANTIDOTE_SYNC_LOG: "false"
	ANTIDOTE_ENABLE_LOGGING: "true"
	ANTIDOTE_AUTO_START_READ_SERVERS: "true"


	services:
	dc1n1:
		container_name: dc1n1
		image: antidotedb:local-build
		environment:
		<< : *default-features
		NODE_NAME: "antidote@dc1n1"
		COOKIE: "secret"
		SHORT_NAME: "true"
		ports:
		- "8101:8087"
		# metrics port
		- "8111:3001"
		volumes:
		- ./dc1/node1:/antidote-data

	dc1n2:
		container_name: dc1n2
		image: antidotedb:local-build
		environment:
		<< : *default-features
		NODE_NAME: "antidote@dc1n2"
		COOKIE: "secret"
		SHORT_NAME: "true"
		ports:
		- "8102:8087"
			# metrics port
		- "8112:3001"
		volumes:
		- ./dc1/node2:/antidote-data

	link-cluster-1:
		image: peterzel/antidote-connect
		command: ['--createDc', 'dc1n1:8087', 'antidote@dc1n2']
		depends_on:
		- dc1n1
		- dc1n2




	dc2n1:
		container_name: dc2n1
		image: antidotedb:local-build
		environment:
		<< : *default-features
		NODE_NAME: "antidote@dc2n1"
		COOKIE: "secret"
		SHORT_NAME: "true"
		ports:
		- "8201:8087"
		- "8211:3001"
		volumes:
		- ./dc2/node1:/antidote-data

	dc2n2:
		container_name: dc2n2
		image: antidotedb:local-build
		environment:
		<< : *default-features
		NODE_NAME: "antidote@dc2n2"
		COOKIE: "secret"
		SHORT_NAME: "true"
		ports:
		- "8202:8087"
		- "8212:3001"
		volumes:
		- ./dc2/node2:/antidote-data

	link-cluster-2:
		image: peterzel/antidote-connect
		command: ['--createDc', 'dc2n1:8087', 'antidote@dc2n2']
		depends_on:
		- dc2n1
		- dc2n2

	link-dcs:
		image: peterzel/antidote-connect
		command: ['--connectDcs', 'dc1n1:8087', 'dc2n1:8087']
		depends_on:
		- dc1n1
		- dc1n2
		- dc2n1
		- dc2n2
		- link-cluster-1
		- link-cluster-2
