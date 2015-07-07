Param(
   [Parameter(Mandatory=$True)]
   [string]$slnpath
)

$script:prj_name_list = [string[]]@()
$script:prj_id_list = [string[]]@()
$script:prj_name_list_query = [string[]]@()
$script:prj_id_list_query = [string[]]@()
$script:path = ""
$script:dot_path = ""

$script:path = $slnpath #"E:\\study\\code\\vs\\gtest-1.7.0\\msvc\\gtest.sln"
$script:dot_path = "$script:path.txt"

function append($str)
{
    $str | out-file $script:dot_path -append -encoding ASCII
}

"digraph G {" | out-file $script:dot_path -encoding ASCII
append "rankdir=BT;"

GC $script:path | ForEach-Object {
    $line = $_
    if ($line -like "Project(`"{*")
    {
        $array = $line.split("`"");
        $name = $array[3]
        $id = $array[7]
        $script:prj_name_list_query += $name
        $script:prj_id_list_query += $id.substring(1, $id.length-2)
    }
}

GC $script:path | ForEach-Object {
    $line = $_
    if ($line -like "Project(`"{*")
    {
        $array = $line.split("`"");
        $name = $array[3]
        $id = $array[7]
        $script:prj_name_list += $name
        $script:prj_id_list += $id
        append "$name[shape=box,fontname=consolas];"
    }
    if ($line -like "*ProjectSection(*")
    {
        $name = $script:prj_name_list[$script:prj_name_list.length - 1]
        append "$name->{"
    }
    if ($line -like "*{*} = {*}*")
    {
        $right = $line.lastindexof("}")
        $left = $line.lastindexof("{")
        $dep_id = $line.substring($left+1, $right-$left-1)
        for ($i = 0; $i -lt $script:prj_id_list_query.length; $i++)
        {
            $cur_id = $script:prj_id_list_query[$i]
            if ( $dep_id -like "$cur_id")
            {
                $dep_name = $script:prj_name_list_query[$i]
                append "$dep_name;"
            }
        }
    }
    if ($line -like "*EndProjectSection*")
    {
        append "};"
    }
}
append "}"