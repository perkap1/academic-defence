extends RefCounted
# 4 flight + 2 hit + 3 defeat poses, isolated from the supplied sheet.
# Every pose keeps the same 240x270 canvas, source scale and aircraft pivot.
static func create() -> Dictionary:
 var result={}
 for row in range(3):
  var direction=["side","back","front"][row]
  result[direction]=[]
  for i in range(9):result[direction].append(load("res://assets/enemies_v023/%d_%d.png"%[row,i]))
 return result
