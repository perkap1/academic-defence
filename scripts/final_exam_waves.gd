extends RefCounted
# Authored wave mixes and entry cycles; no bosses or new enemy mechanics.
const MIXES:=[[6, 2, 0, 0, 0], [7, 2, 1, 0, 0], [8, 3, 1, 0, 0], [9, 3, 2, 0, 0], [9, 4, 3, 1, 1], [10, 4, 4, 2, 1], [10, 5, 5, 2, 2], [11, 6, 5, 3, 2], [10, 7, 7, 3, 3], [11, 8, 7, 4, 4], [11, 9, 9, 5, 4], [12, 10, 10, 5, 5], [12, 11, 11, 6, 6], [12, 12, 12, 7, 7], [12, 13, 14, 7, 8], [13, 14, 14, 8, 9], [13, 15, 16, 8, 10], [14, 16, 17, 9, 10], [14, 17, 19, 10, 12], [15, 18, 21, 11, 13], [16, 20, 24, 12, 14], [20, 24, 30, 16, 18]]
const ENTRIES:=[[0], [0, 1], [0, 2], [1, 3], [0, 1, 2, 3], [0, 2, 3], [1, 2, 3], [0, 1, 2, 3], [0, 2], [1, 3], [0, 1, 2, 3], [2, 3], [0, 1, 2, 3], [0, 2, 3, 3], [1, 2, 3], [0, 1, 2, 3], [0, 1, 3, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3]]
const INTERVALS:=[1.8,1.7,1.65,1.6,1.5,1.45,1.4,1.35,1.3,1.25,1.2,1.15,1.1,1.05,1.0,0.95,0.9,0.85,0.8,0.78,0.75,0.70]
static func kind(wave:int,index:int)->String:
 var mix:Array=MIXES[wave-1]
 var total:int=mix.reduce(func(a,b):return a+b,0)
 # Weighted fair ordering spreads every type rather than spawning one solid block.
 var used=[0,0,0,0,0]
 var chosen:=0
 for n in range(index+1):
  var best:=-INF
  for k in range(5):
   var deficit:float=(n+1)*float(mix[k])/total-used[k]
   if used[k]<mix[k] and deficit>best:
    best=deficit;chosen=k
  used[chosen]+=1
 return ["normal","pe","bookworm","snack","pilot"][chosen]
static func route(wave:int,index:int)->int:
 var entries:Array=ENTRIES[wave-1]
 return entries[index%entries.size()]
static func notice(wave:int)->String:
 if wave==22:return "THE FINAL EXAM - ALL ENTRANCES!"
 var names=["A","B","C","D"]
 var active:PackedStringArray=[]
 for index in ENTRIES[wave-1]:
  if not names[index] in active:active.append(names[index])
 return "ENTRANCES: "+" + ".join(active)
