CREATE OR REPLACE PACKAGE Atsp_SOL_Parts_Pkg AS
TYPE AT_ITEMCODETYPE IS TABLE OF SW_ITEM_MASTER.swItemCode%TYPE
                        INDEX BY binary_integer;
TYPE AT_ITEMSERIAL   IS TABLE OF SW_SHIPMENT.SWSERIALNUMBER%TYPE
                        INDEX BY binary_integer;

/******************************************************************************

   Author                          	: Robert Bondaruk, PeopleSoft Consulting
   Date Written                    	: 07/25/2000
   Objects invoking this procedure 	: Service_Order
   Events Called from              	: Part Number Display Parms
   Detailed Description            	:
      This proc derives the display parms for the Part Number,
	  atAddPartNumberId|SW_ITEM_MASTER.swItemCode, field on the Service Order
	  Material Log screen.
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

procedure Atsp_SOL_Parts
  (locale         IN  int,
   SOid           IN  SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   V_ITEMCODETYPE OUT AT_ITEMCODETYPE,
   batch_size     IN  int,
   out_batch_size IN  out int,
   status         OUT int);

PROCEDURE Atsp_SOL_Get_SN
  (locale         IN  int,
   SOid           IN  SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   pITEMCODE      IN  SW_ITEM_MASTER.SWITEMCODE%TYPE,
   V_AT_ITEMSERIAL OUT AT_ITEMSERIAL,
   batch_size     IN  int,
   out_batch_size IN OUT int,
   status         OUT int);

END Atsp_SOL_Parts_Pkg;
/

CREATE OR REPLACE PACKAGE BODY Atsp_SOL_Parts_Pkg AS
  CURSOR c1 (SOid SW_SERVICE_ORDER.swServiceOrderId%TYPE) IS
  SELECT DISTINCT IM.swItemCode as IC
  FROM SW_ITEM_MASTER IM,
       SW_PROD_RELEASE PR,
	   SW_SERVICE_ORD_LN SOL
  WHERE SOL.swServiceOrderId   = SOid
    AND SOL.swRcvProdReleaseId = PR.swProdReleaseId
    AND PR.swItemId            = IM.swItemMasterId
  ORDER BY IM.swItemCode;

  CURSOR get_sn (SOid SW_SERVICE_ORDER.swServiceOrderId%TYPE, IMID SW_ITEM_MASTER.SWITEMMASTERID%TYPE) IS
  SELECT SWSERIALNUMBER
  FROM  SW_SHIPMENT SH
  WHERE SH.SWSERVICEORDERID  = SOid
    AND SH.SWITEMMASTERID    = IMID
  ORDER BY SH.SWSERIALNUMBER;

PROCEDURE Atsp_SOL_Parts
  (locale         IN  int,
   SOid           IN  SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   V_ITEMCODETYPE  OUT AT_ITEMCODETYPE,
   batch_size     IN  int,
   out_batch_size IN OUT int,
   status         OUT int)

IS

   i   binary_integer;

BEGIN

   out_batch_size := 0;
   status := 0;
   i := 0;

   IF NOT c1%ISOPEN THEN
      OPEN c1 (SOid) ;
   END IF;

   FOR i in 1..batch_size
   LOOP
      FETCH c1 INTO V_ITEMCODETYPE(i);

      IF c1%NOTFOUND THEN
         CLOSE c1;
         RETURN ;
      ELSE
         out_batch_size := out_batch_size + 1;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      status := 77777;

END Atsp_SOL_Parts;

/******************************************************************************

   Author                          	: Don Wylie, PeopleSoft Consulting
   Date Written                    	: 08/01/2000
   Objects invoking this procedure 	: Service_Order
   Events Called from              	:
   Detailed Description            	:
      This proc derives the drop down for the serial number,
	  ATADDPARTNUMSERIAL field on the Service Order
	  Material Log screen.
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

PROCEDURE Atsp_SOL_Get_SN
  (locale         IN  int,
   SOid           IN  SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   pITEMCODE      IN  SW_ITEM_MASTER.SWITEMCODE%TYPE,
   V_AT_ITEMSERIAL OUT AT_ITEMSERIAL,
   batch_size     IN  int,
   out_batch_size IN OUT int,
   status         OUT int)

IS
   v_ItemId  SW_ITEM_MASTER.SWITEMMASTERID%TYPE;
   i   binary_integer;

BEGIN

   out_batch_size := 0;
   status := 0;
   i := 0;
   IF SOid is null then
   	  return;
   end if;
   If pitemcode is null then
      return;
   end if;
   Begin
     Select SWITEMMASTERID INTO V_itemId
	   from sw_item_master
	   where switemcode = pItemCode;
	 Exception
	   when others then
	      return;
   End;

   IF NOT get_sn%ISOPEN THEN
      OPEN get_sn (SOid, v_ItemId) ;
   END IF;

   FOR i in 1..batch_size
   LOOP
      FETCH get_sn INTO V_AT_ITEMSERIAL(i);

      IF get_sn%NOTFOUND THEN
         CLOSE get_sn;
         RETURN ;
      ELSE
         out_batch_size := out_batch_size + 1;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      status := 77777;

END Atsp_SOL_Get_SN;

END Atsp_SOL_Parts_Pkg;
/

