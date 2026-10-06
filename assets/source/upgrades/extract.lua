-- Run from project root: aseprite --batch --script-param out=assets/upgrades --script assets/source/upgrades/extract.lua
local out=app.params['out'] or 'assets/upgrades'
local sets={
 {name='book_2',file='assets/source/upgrades/book_level2.png',cols=5,top=100,bottom=652,scale=.28,foot=180},
 {name='book_3',file='assets/source/upgrades/book_level3.png',cols=5,top=170,bottom=756,scale=.30,foot=180},
 {name='blackboard_2',file='assets/source/upgrades/blackboard_levels.png',centers={250,595,940,1285,1630,1995},top=12,bottom=295,scale=.46,foot=185},
 {name='blackboard_3',file='assets/source/upgrades/blackboard_levels.png',centers={220,584,946,1308,1660,1995},top=340,bottom=666,scale=.43,foot=185}
}
for _,s in ipairs(sets) do
 local src=Image{fromFile=s.file}
 for i=0,4 do
  local sourceIndex=i
  if s.centers and i==4 then sourceIndex=5 end
  local left,right
  if s.centers then
   left=math.max(0,math.floor(s.centers[sourceIndex+1]-180));right=math.min(src.width,left+360)
  else left=math.floor(sourceIndex*src.width/s.cols);right=math.floor((sourceIndex+1)*src.width/s.cols) end
  local crop=Image(src,Rectangle(left,s.top,right-left,s.bottom-s.top))
  -- Align the stone base, not the moving pages or attack glow.
  local lo,hi=crop.width,0
  for y=crop.height-16,crop.height-4 do
   for x=0,crop.width-1 do
    if app.pixelColor.rgbaA(crop:getPixel(x,y))>240 then lo=math.min(lo,x);hi=math.max(hi,x) end
   end
  end
  local center=hi>lo and (lo+hi)/2 or crop.width/2
  crop:resize(math.floor(crop.width*s.scale+.5),math.floor(crop.height*s.scale+.5))
  local canvas=Image(180,188,ColorMode.RGB)
  canvas:drawImage(crop,Point(math.floor(90-center*s.scale+.5),s.foot-crop.height))
  canvas:saveAs(out..'/'..s.name..'_'..i..'.png')
 end
end
print('Exported 20 aligned tower frames')
