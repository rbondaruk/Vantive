CREATE OR REPLACE PACKAGE Atsp_Unconsume_Pkg IS

PROCEDURE Atsp_Unconsume
  (locale			 	IN      int,
   SOid					IN      SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   swUser				IN		SW_USER.swUser%TYPE,
--   ErrorCode			OUT		SW_VALID_CODE.swCode%TYPE,
   batch_size			IN      int,
   out_batch_size		IN OUT  int,
   status				OUT     int);

END Atsp_Unconsume_Pkg;
/

CREATE OR REPLACE PACKAGE BODY Atsp_Unconsume_Pkg IS

/******************************************************************************

   Author                          	: Robert Bondaruk, PeopleSoft Consulting
   Date Written                    	: 07/20/2000
   Objects invoking this procedure 	: Service_Order_Line
   Events Called from              	: Field Changed Event
   Detailed Description            	:
      This proc creates 'Unconsumed' records in the SW_PARTS_USED table.  It
	  is called by the Field Changed event on the Service Order Material Log
	  'Process Parts Used' button.  It sets the SWUSAGE column to the value of
	  'Unconsumed Part' for all records in the SW_SERVICE_ORD_LN table that
	  are not already entered in the SW_PARTS_USED table.
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

PROCEDURE Atsp_Unconsume
  (locale			 	IN      int,
   SOid					IN      SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   swUser				IN		SW_USER.swUser%TYPE,
--   ErrorCode			OUT		SW_VALID_CODE.swCode%TYPE,
   batch_size			IN      int,
   out_batch_size		IN OUT  int,
   status				OUT     int)

IS

CURSOR c1
  (SOid	SW_SERVICE_ORDER.swServiceOrderId%TYPE,
   cs_SOLT_MATERIAL_REQUEST SW_SERVICE_ORD_LN.swType%TYPE)

IS
   SELECT swItemId, SUM(swOrigQuantity) As Qty
   FROM SW_SERVICE_ORD_LN
   WHERE swServiceOrderId = SOid
   AND swType = cs_SOLT_MATERIAL_REQUEST
   GROUP BY swItemId, swOrigQuantity
   ORDER BY swItemId;

cs_SOLT_MATERIAL_REQUEST SW_SERVICE_ORD_LN.swType%TYPE;
cs_MU_NOT_USED           SW_PARTS_USED.swUsage%Type;
cs_RR_99                 SW_PARTS_USED.atReasonRemoved%TYPE;
PUid                     SW_PARTS_USED.swPartsUsedId%TYPE;
LoggedQty                SW_PARTS_USED.swAddQty%TYPE;
WorkQty                  SW_SERVICE_ORD_LN.swOrigQuantity%TYPE;
Tracked                  SW_ITEM_MASTER.swTrackBySerial%TYPE;
b_in                     int;
b_out                    int;
cs_rc                    int;
maxid_reached            EXCEPTION;

BEGIN
   out_batch_size := 0;
   status         := 0;
   b_in           := 1;
   b_out          := 0;
   cs_rc          := 0;

   Swsp_A_Code_Val_Pkg.swsp_a_code_val(locale,'AT Material Usage',
      'MU_NOT_USED',cs_MU_NOT_USED,b_in,b_out,cs_rc);

   IF NVL(cs_rc,1) <> 0 THEN
      status := cs_rc;
--	  SELECT cs_rc INTO ErrorCode FROM SW_CONFIGURATION;
      RETURN;
   END IF;

   Swsp_A_Code_Val_Pkg.swsp_a_code_val(locale,'AT Reason Remove',
      'RR_99',cs_RR_99,b_in,b_out,cs_rc);

   IF NVL(cs_rc,1) <> 0 THEN
      status := cs_rc;
--	  SELECT cs_rc INTO ErrorCode FROM SW_CONFIGURATION;
      RETURN;
   END IF;

   Swsp_A_Code_Val_Pkg.swsp_a_code_val(locale,'Service Order Line Type',
      'SOLT_MATERIAL_REQUEST',cs_SOLT_MATERIAL_REQUEST,b_in,b_out,cs_rc);

   IF NVL(cs_rc,1) <> 0 THEN
      status := cs_rc;
--	  SELECT cs_rc INTO ErrorCode FROM SW_CONFIGURATION;
      RETURN;
   END IF;

   FOR c1_rec IN c1 (SOid, cs_SOLT_MATERIAL_REQUEST)
   LOOP
      BEGIN
         SELECT SUM(swAddQty)
         INTO LoggedQty
         FROM SW_PARTS_USED
         WHERE swServiceOrderId = SOId
		 AND atAddPartNumberId = c1_rec.swItemId
		 GROUP BY swAddQty;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
	           LoggedQty := 0;
      END;

	  IF LoggedQty < c1_rec.Qty THEN
	  BEGIN
	  	 WorkQty := (c1_rec.Qty - LoggedQty);

		 BEGIN
		    SELECT swTrackBySerial
		    INTO Tracked
		    FROM SW_ITEM_MASTER
		    WHERE swItemMasterId = c1_rec.swItemId;
			   EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			      Tracked := 0;
         END;
		 
		 IF Tracked = 1 THEN
--		    Insert Material Log entires for all serialized parts on the service order
            status := 0;
		 ELSE
            BEGIN
               SELECT swsp_get_publishid(SW_PARTS_USED_SQ.nextval)
               INTO PUid
               FROM SYS.DUAL;
                  EXCEPTION
                  WHEN maxid_reached THEN
			         BEGIN
	                    status := 7390;
--			            SELECT '7390' INTO ErrorCode FROM SW_CONFIGURATION;
	                    RETURN;
			         END;
            END;

            BEGIN
	           INSERT INTO SW_PARTS_USED (
		          swPartsUsedId,
			      swServiceOrderId,
			      atAddPartNumberId,
			      atAddPartNumSerial,
			      swUsage,
			      swDateChanged,
			      swReasonRemoved,
			      swUpdateConf,
			      swAddQty,
			      swCreatedBy,
			      swDateCreated)
		       VALUES (
		          PUid,
			      SOid,
			      c1_rec.swItemId,
			      NULL,
			      cs_MU_NOT_USED ,
			      SYSDATE(),
			      cs_RR_99,
			      0,
			      WorkQty,
			      swUser,
			      SYSDATE());
            END;
         END IF;
      END;
      END IF;
   END LOOP;
   COMMIT;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      status := 0;
--	  SELECT '0' INTO ErrorCode FROM SW_CONFIGURATION;
   WHEN OTHERS THEN
      status := 77777;
--	  SELECT '77777' INTO ErrorCode FROM SW_CONFIGURATION;

END Atsp_Unconsume;
END Atsp_Unconsume_Pkg;
/

