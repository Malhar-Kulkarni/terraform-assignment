## Tasks - Create a secure and cost-effective architecture using terraform template provided.
Write a terraform code to create below resources (Need not apply it, just a clean plan would do).

1) A network with 1 VPC, 1 Public subnet, public route table, 1 Private subnet, private route table.
2) A load balancer security group allowing access from internet.
3) A web security group allowing access from load balancer.
4) A database security group allowing access to db port from webserver.
5) An EC2 instance in Private subnet with user-data to install nodejs,nginx.
6) A Mysql RDS in private subnet.
7) An application load balancer and a target group with instance attached.

### NOTE - Use terraform version 0.12.30. Can use terraform modules or resources.
