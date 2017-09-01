CREATE OR REPLACE PACKAGE Atsp_Val_So_Pkg IS

PROCEDURE Atsp_Val_So
  (locale			 	IN      int,
   SOId					IN      SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   SOStatus				IN		SW_VALID_CODE.swValue%TYPE,
   batch_size			IN      int,
   out_batch_size		IN OUT  int,
   status				OUT     int);

END Atsp_Val_So_Pkg;
/

CREATE OR REPLACE PACKAGE BODY Atsp_Val_So_Pkg IS

/******************************************************************************

   Author                          	: Robert Bondaruk, PeopleSoft Consulting
   Date Written                    	: 07/13/2000
   Objects invoking this procedure 	: Service_Order
   Events Called from              	: PreSave Event
   Detailed Description            	:
      This proc checks to verify that all service orders lines on a service
      order that are material requests have corresponding material log entires.
      For each Product Release on the Service Order, get the total quantity that
      are Material Requests on all Service Order Lines.  For each Product
      Release, get the total quantity that are Installed on all Material Log
      lines. For each Product Release, compare the quantities, if they are
      equal, exit the proc with no error.  If they are unequal, exit the proc
      with an error message which will inform the user the need to complete the
      Material Log so that all the Product Releases on the Service Order Lines
      are accounted for.
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

PROCEDURE Atsp_Val_So
  (locale			 	IN      int,
   SOId					IN      SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   SOStatus				IN		SW_VALID_CODE.swValue%TYPE,
   batch_size			IN      int,
   out_batch_size		IN OUT  int,
   status				OUT     int)

IS

CURSOR c1 (cs_MATERIAL_REQUEST SW_VALID_CODE.swValue%TYPE)

IS

SELECT swItemId, SUM(swOrigQuantity) As Qty
FROM SW_SERVICE_ORD_LN
WHERE swServiceOrderId = SOid
AND swType = cs_MATERIAL_REQUEST
GROUP BY swItemId, swOrigQuantity
ORDER BY swItemId;

cs_MATERIAL_REQUEST  SW_VALID_CODE.swValue%TYPE;
cs_AT_COMPLETED      SW_VALID_CODE.swValue%TYPE;
LoggedQty            SW_PARTS_USED.swAddQty%Type;
b_in                 int;
b_out                int;
cs_rc                int;

BEGIN
   out_batch_size := 0;
   status         := 0;
   b_in           := 1;
   b_out          := 0;
   cs_rc          := 0;

   Swsp_A_Code_Val_Pkg.swsp_a_code_val(locale,'Service Order Line Type',
      'SOLT_MATERIAL_REQUEST',cs_MATERIAL_REQUEST,b_in,b_out,cs_rc);

   IF NVL(cs_rc,1) <> 0 THEN
      status := cs_rc;
      RETURN;
   END IF;

   Swsp_A_Code_Val_Pkg.swsp_a_code_val(locale,'AT Service Order Status',
      'AT_COMPLETED',cs_AT_COMPLETED,b_in,b_out,cs_rc);

   IF NVL(cs_rc,1) <> 0 THEN
      status := cs_rc;
      RETURN;
   END IF;

   IF SOStatus <> cs_AT_COMPLETED THEN
      status := 0;
      RETURN;
   END IF;

   FOR c1_rec IN c1(cs_MATERIAL_REQUEST)
   LOOP
      BEGIN
	     BEGIN
            SELECT SUM(swAddQty)
            INTO LoggedQty
            FROM SW_PARTS_USED
            WHERE swServiceOrderId = SOId
            AND atAddPartNumberId = c1_rec.swItemId;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
	              LoggedQty := 0;
         END;

		 LoggedQty := NVL(LoggedQty,0);
		 
         IF (c1_rec.Qty <> LoggedQty) THEN
            BEGIN
			   status := 8178;
               RETURN;
            END;
         END IF;
      END;

   END LOOP;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      status := 8178;
   WHEN OTHERS THEN
      status := 77777;

END Atsp_Val_So;
END Atsp_Val_So_Pkg;
/