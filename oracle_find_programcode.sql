CREATE OR REPLACE PROCEDURE FIND_PROGRAM_CODE IS
cursor c1 is
	   select swname,swtext from sw_basic_script;
programcode varchar2(32000);
cnt int(3);
functioname varchar2(200);
/******************************************************************************
   NAME:       FIND_PROGRAM_CODE
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/28/99             1. Created this procedure.

   PARAMETERS:
   INPUT:
   OUTPUT:
   RETURNED VALUE:
   CALLED BY:
   CALLS:
   EXAMPLE USE:     FIND_PROGRAM_CODE;
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:
******************************************************************************/
BEGIN
	 FOR sel_rec IN c1
  	 LOOP
	 	 programcode := sel_rec.swtext;
		 cnt := INSTR(programcode,'Bondaruk');
		 If cnt > 0 Then
		 	functioname := sel_rec.swname;
			insert into bondaruk_temp
			(functionname)
			values (functioname);
			commit;
		 End If;
	 END LOOP;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
       Null;
END FIND_PROGRAM_CODE;
/

