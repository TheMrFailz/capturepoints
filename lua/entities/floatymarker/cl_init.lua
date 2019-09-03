include('shared.lua')


local material = Material( "engine/lightsprite" )

function ENT:Draw()
	self:DrawModel()
	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		render.SetMaterial( material ) -- Tell render what material we want, in this case the flash from the gravgun
		render.DrawSprite( self:GetPos(), 128, 128, self:GetColor() ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
	
end
