output "cluster" {
  value = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}