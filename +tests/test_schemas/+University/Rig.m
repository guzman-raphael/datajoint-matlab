%{
# Rig
rig_id  : char(4)
---
#-> [unique] University.Student
#-> [nullable] University.Student
#-> University.Student
-> [nullable, unique] University.Student
%}
classdef Rig < dj.Manual
end 