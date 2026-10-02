-- Aseprite authoring script: four small transparent frames per ambient loop.
local out = assert(app.params['out'], 'Pass --script-param out=EXPORT_DIRECTORY/')
local colors = {
 water={67,164,189,150}, foam={161,215,215,125},
 green={84,142,35,190}, light={110,157,41,170}, dark={59,117,39,160}
}
local function rect(im,x,y,w,h,c)
 local p=app.pixelColor.rgba(table.unpack(colors[c]))
 for yy=y,y+h-1 do for xx=x,x+w-1 do
  if xx>=0 and yy>=0 and xx<im.width and yy<im.height then im:drawPixel(xx,yy,p) end
 end end
end
local kinds={{'water',32,12,0.34},{'waterfall',12,32,0.2},{'bush',22,16,0.5},{'leaves',26,14,0.6},{'plant',16,22,0.5}}
for _,spec in ipairs(kinds) do
 local name,w,h,duration=table.unpack(spec)
 local sprite=Sprite(w,h,ColorMode.RGB)
 sprite.layers[1].name=name
 for f=0,3 do
  if f>0 then sprite:newEmptyFrame(f+1) end
  sprite.frames[f+1].duration=duration
  local im=Image(w,h,ColorMode.RGB)
  local sway=({0,1,0,-1})[f+1]
  if name=='water' then
   rect(im,2+sway,3,10,2,'water'); rect(im,17-sway,7,9,2,'water')
   rect(im,5+sway,2,4,1,'foam'); rect(im,22-sway,6,3,1,'foam')
  elseif name=='waterfall' then
   for y=-8,32,8 do
    rect(im,2,y+f*2,2,4,'foam');rect(im,7,y+4+f*2,2,3,'water')
   end
  elseif name=='bush' or name=='leaves' then
   rect(im,4+sway,6,7,3,'green');rect(im,12+sway,4,6,3,'green')
   rect(im,6+sway,5,4,2,'light');rect(im,14+sway,3,3,2,'light')
   rect(im,10+sway,10,6,2,'dark')
  else
   rect(im,7,13,2,8,'dark');rect(im,7+sway,5,2,10,'green')
   rect(im,3+sway,9,4,2,'green');rect(im,9+sway,7,4,2,'light')
   rect(im,2+sway,7,2,3,'light');rect(im,12+sway,5,2,3,'green')
  end
  sprite:newCel(sprite.layers[1],f+1,im,Point(0,0))
  im:saveAs(out..name..'_'..f..'.png')
 end
 local tag=sprite:newTag(1,4);tag.name='loop'
 sprite:saveAs(out..'source/'..name..'.aseprite')
 sprite:close()
end
print('Created five editable Aseprite loops and twenty PNG frames')

