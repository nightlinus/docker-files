FROM rabbitmq:3.7-management
RUN rabbitmq-plugins enable --offline rabbitmq_consistent_hash_exchange rabbitmq_shovel rabbitmq_shovel_management
