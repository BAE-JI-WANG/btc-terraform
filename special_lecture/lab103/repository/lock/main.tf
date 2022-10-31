resource "aws_dynamodb_table" "lock" {
  name            = var.lock_table_name

  // The number of read units for this table
  read_capacity   = 5

  // The number of write units for this table.
  write_capacity  = 5

  // The attribute to use as the hash (partition) key.
  hash_key = "LockID"

  /*
    List of nested attribute definitions.
    Only required for hash_key and range_key attributes. Each attribute has two properties:
      name - (Required) The name of the attribute
      type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data
  */
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.lock_table_name
    Environment = var.environment
  }
}