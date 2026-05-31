# Narrative
# --------
# #  Example 6: HTML-like Table inside the diagram  #
#
# Extracted from stzdotcodetest.ring, block #12.

load "../../../stzBase.ring"

#-------------------------------------------------#

pr()

Dot = XDot()
Dot.SetCode('
digraph DataCard {
    graph [
        bgcolor="#F5F5F5"
        pad=0.5
    ]
    
    node [shape=plaintext]
    
    user_card [label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="8" BGCOLOR="white">
        <TR>
            <TD BGCOLOR="#1976D2" COLSPAN="2">
                <FONT COLOR="white" POINT-SIZE="14"><B>User Profile</B></FONT>
            </TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Name</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">John Doe</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Email</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">john.doe@company.com</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>ID</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">EMP-12345</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Role</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">Senior Developer</TD>
        </TR>
        <TR>
            <TD BGCOLOR="#4CAF50" COLSPAN="2">
                <FONT COLOR="white"><B>Status: Active</B></FONT>
            </TD>
        </TR>
    </TABLE>>]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.49 second(s) in Ring 1.24
