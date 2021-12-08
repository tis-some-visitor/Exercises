data BT:
  | leaf
  | node(v :: Number, l :: BT, r :: BT)
end


fun flatten-inner(b :: BT, acc) -> List:
  cases (BT) b:
    | leaf => empty
    | node(v, l, r) =>
      acc.push(v) + (flatten-inner(l, acc) + (flatten-inner(r, acc)))
  end
end
check: 
  tree-leaf = (leaf)
  tree-nodes = node(1, leaf, node(8, leaf, leaf))
  flatten-inner(tree-leaf, [list: ]) is [list: ]
  flatten-inner(tree-nodes, [list: ]) is [list: 1, 8]
end


fun flatten-the-tree(b :: BT) -> List:
  flatten-inner(b, [list: ])
end