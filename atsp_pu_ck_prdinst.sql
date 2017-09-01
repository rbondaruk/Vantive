CREATE OR REPLACE PACKAGE atsp_pu_ck_prdinst_pkg AS

/******************************************************************************

   Author                          	: ?
   Date Written                    	: ?
   Objects invoking this procedure 	: Service Order
   Events Called from              	: Insert Record on the Material Log
   Detailed Description            	:
      This proc checks to see is if an serialized part has an installed product
	  record.  If it doesn't the proc return error code 7716. 
   Modified By                     	: Robert Bondaruk, PeopleSoft Consulting
   Modified Date                   	: 7/26/2000
   Modified Desc.                   :
      The 'AT Material Usage' codeset was modified.  The code 'Exchanged' was
	  removed from the codeset.  The code 'Unconsumed' was replaced with
	  'Part Not Used' 

******************************************************************************/

   PROCEDURE atsp_pu_ck_prdinst
               (locale		 IN	int,
		    usage          IN	SW_VALID_CODE.swValue%TYPE,
                addexcept      IN 	SW_PARTS_USED.swAddException%TYPE,
                delexcept      IN   SW_PARTS_USED.swDelException%TYPE,
                addinstprodid  IN   SW_PARTS_USED.swAddInstProdId%TYPE,
                addprodrelid   IN   SW_PROD_RELEASE.swProdReleaseId%TYPE,
                delinstprodid  IN   SW_PARTS_USED.swDelInstProdId%TYPE,
                delprodrelid   IN   SW_PROD_RELEASE.swProdReleaseId%TYPE,
		mobileflag     IN   int,
          batch_size     IN   INTEGER,
                out_batch_size IN OUT INTEGER,
                status         OUT  INTEGER);
END atsp_pu_ck_prdinst_pkg;
/

CREATE OR REPLACE PACKAGE BODY atsp_pu_ck_prdinst_pkg
AS
   PROCEDURE atsp_pu_ck_prdinst
               (locale		 IN	int,
		    usage          IN	SW_VALID_CODE.swValue%TYPE,
                addexcept      IN 	SW_PARTS_USED.swAddException%TYPE,
                delexcept      IN   SW_PARTS_USED.swDelException%TYPE,
                addinstprodid  IN   SW_PARTS_USED.swAddInstProdId%TYPE,
                addprodrelid   IN   SW_PROD_RELEASE.swProdReleaseId%TYPE,
                delinstprodid  IN   SW_PARTS_USED.swDelInstProdId%TYPE,
                delprodrelid   IN   SW_PROD_RELEASE.swProdReleaseId%TYPE,
		mobileflag     IN   int,
                batch_size     IN   INTEGER,
                out_batch_size IN OUT INTEGER,
                status         OUT  INTEGER)
   IS
      track       SW_PROD_RELEASE.swTracking%TYPE;
      taddexcept  SW_PARTS_USED.swAddException%TYPE;
      tdelexcept  SW_PARTS_USED.swDelException%TYPE;
	cs_rc		int;
	val_PT_SERIALIZED		SW_VALID_CODE.swValue%Type;
	val_MU_DE_INSTALLED	    SW_VALID_CODE.swValue%Type;
    val_MU_CONSUMED		    SW_VALID_CODE.swValue%Type;
	val_MU_INSTALLED		SW_VALID_CODE.swValue%Type;
	cs_MU_NOT_USED          SW_VALID_CODE.swValue%Type;

	lv_batch_size		int;
	lv_out_batch		int;
   BEGIN
      /* Purpose is to make sure that installed products are specIFied when
       * tracking is set to serialized.
       */
	status	   := 0;
      out_batch_size := 0;
      lv_batch_size  := 1;
      cs_rc		   := 0;

	swsp_a_code_val_pkg.swsp_a_code_val(locale, 'Product Tracking',
		'PT_SERIALIZED', val_PT_SERIALIZED, lv_batch_size,
		lv_out_batch, cs_rc);

		if  nvl(cs_rc,1) <> 0 then
		    status := cs_rc;
			return;
            end if;

	swsp_a_code_val_pkg.swsp_a_code_val(locale, 'AT Material Usage',
		'MU_DE_INSTALLED', val_MU_DE_INSTALLED, lv_batch_size,
		lv_out_batch, cs_rc);

		if  nvl(cs_rc,1) <> 0 then
		    status := cs_rc;
			return;
            end if;

	swsp_a_code_val_pkg.swsp_a_code_val(locale, 'AT Material Usage',
		'MU_CONSUMED', val_MU_CONSUMED, lv_batch_size,
		lv_out_batch, cs_rc);

		if  nvl(cs_rc,1) <> 0 then
		    status := cs_rc;
			return;
            end if;

	swsp_a_code_val_pkg.swsp_a_code_val(locale, 'AT Material Usage',
		'MU_NOT_USED', cs_MU_NOT_USED, lv_batch_size,
		lv_out_batch, cs_rc);

		if  nvl(cs_rc,1) <> 0 then
		    status := cs_rc;
			return;
            end if;

	swsp_a_code_val_pkg.swsp_a_code_val(locale, 'AT Material Usage',
		'MU_INSTALLED', val_MU_INSTALLED, lv_batch_size,
		lv_out_batch, cs_rc);

		if  nvl(cs_rc,1) <> 0 then
		    status := cs_rc;
			return;
            end if;

      taddexcept 	   := NVL (addexcept, 0);
      tdelexcept     := NVL (delexcept, 0);

      IF (taddexcept = 1 AND tdelexcept = 1) OR usage = val_MU_CONSUMED THEN
         status := 0;
         RETURN;
      END IF;

	if mobileflag = 0 then
	/* Check installed or added product */
      IF usage = val_MU_INSTALLED THEN
         IF taddexcept <> 1 AND addinstprodid IS NULL THEN
            BEGIN
               SELECT swTracking
                 INTO track
                 FROM SW_PROD_RELEASE
                WHERE swProdReleaseId = addprodrelid;
            EXCEPTION WHEN NO_DATA_FOUND THEN
		track := to_char(null);
                status := 1;
                RETURN;
            END;
            IF nvl(track, '!@#$') = val_PT_SERIALIZED THEN
               status := 7716;
               RETURN;
            END IF;
         END IF;
      END IF;
      end if;
	/* Check de-installed product */
      IF usage = val_MU_DE_INSTALLED THEN
         IF tdelexcept <> 1 AND delinstprodid IS NULL THEN
            BEGIN
               SELECT swTracking
                 INTO track
                 FROM SW_PROD_RELEASE
                WHERE swProdReleaseId = delprodrelid;
            EXCEPTION WHEN NO_DATA_FOUND THEN
		   track := to_char(null);
               status := 1;
               RETURN;
            END;
            IF nvl(track, '!@#$') = val_PT_SERIALIZED THEN
               status := 7717;
               RETURN;
            END IF;
         END IF;
      END IF;

   END  atsp_pu_ck_prdinst;
END  atsp_pu_ck_prdinst_pkg;
/

