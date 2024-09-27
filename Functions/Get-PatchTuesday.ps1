<#
.SYNOPSIS
    Find out when Patch Tuesday is for the current month.

.NOTES
    I totally ripped this off someone that I can't remember.  I'm sorry, but I can't give you credit. I'll look for it and update this when I find it.

#>
function Get-PatchTuesday {
    $Month = Get-Date -Format 'MMMM'
    switch ((Get-Date -Day 1).DayOfWeek) {
        'Tuesday'   {return "Patch Tuesday is on $Month 8th"}
        'Monday'    {return "Patch Tuesday is on $Month 9th"}
        'Sunday'    {return "Patch Tuesday is on $Month 10th"}
        'Saturday'  {return "Patch Tuesday is on $Month 11th"}
        'Friday'    {return "Patch Tuesday is on $Month 12th"}
        'Thursday'  {return "Patch Tuesday is on $Month 13th"}
        'Wednesday' {return "Patch Tuesday is on $Month 14th"}
    }
}