variable "source_path" {
    type = string
}

locals {
    players = jsondecode(file(var.source_path))
}


resource "aws_dynamodb_table" "teams-dynamodb-table" {
    name           = "Teams"
    read_capacity  = 20
    write_capacity = 20
    hash_key       = "TeamTitle"
    range_key      = "PlayerName"

    attribute {
        name = "TeamTitle"
        type = "S"
    }

    attribute {
        name = "PlayerName"
        type = "S"
    }
}

resource "aws_dynamodb_table_item" "the-players" {
    count = length(local.players)

    table_name = aws_dynamodb_table.teams-dynamodb-table.name
    hash_key   = aws_dynamodb_table.teams-dynamodb-table.hash_key
    range_key  = aws_dynamodb_table.teams-dynamodb-table.range_key

    item = jsonencode(local.players[ count.index ])
}