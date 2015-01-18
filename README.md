# logstash
logstash configuration for logstash/elasticsearch/kibana with lumberjack

1. using lumberjack https://github.com/elasticsearch/logstash-forwarder for Linux and windows
2. for windows wrap lumberjack with http://nssm.cc/
3. installing on windows from commandline `nssm.exe install log-forworder-master.exe` with argument for config
4. Creating a self sign certificate for logstash for shipping lumberjack `openssl req -new -x509 -key logstash.key -out logstash.cert -days 3650 -subj /CN=servername`


