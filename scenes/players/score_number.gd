extends MeshInstance3D
var mat=self.get_active_material(0)
func initialize(tx,col):
	var me = mesh as TextMesh
	me.text=str(tx)
	mat.albedo_color=col
