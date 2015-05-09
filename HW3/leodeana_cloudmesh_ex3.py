# coding: utf-8
import cloudmesh
begin_txt = cloudmesh.shell("vm start --cloud=india --image=futuresystems/ubuntu-14.04 --flavor=m1.small")
finish_txt = cloudmesh.shell("vm delete --cloud=india leodeana_1 --force")
f = open('leodeana_cloudmesh_ex3.txt','w')
f.write(str(begin_txt)+"\n"+str(finish_txt) )
f.close()
