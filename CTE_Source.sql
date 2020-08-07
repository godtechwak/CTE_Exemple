 DECLARE @OrgType  INT  
		,@BaseDate NCHAR(8)
		,@DeptSeq  INT
  
  SELECT @OrgType  = 1
        ,@BaseDate = '20200808'
  
  IF @BaseDate = ''
  BEGIN
	  SELECT @BaseDate = CONVERT(NCHAR(8),GETDATE(),112);  
  END
		
  SET @DeptSeq = 1 ;  

  WITH CTE_OrgDept(DeptSeq, UppDeptSeq, Seq, BegDate, EndDate, UMDeptLevel, Remark, DispSeq, OrgCd)  
  AS  
 (  
	-- ¾ÞÄ¿ ¸â¹ö(Anchor Member)
    SELECT DeptSeq, UppDeptSeq, Seq
	      ,BegDate, EndDate,	UMDeptLevel
		  ,Remark,  DispSeq,    CAST('000' AS NVARCHAR(50))  
      FROM _ErrorTable A  
     WHERE A.CompanySeq = 1  
	   AND A.DeptSeq    = @DeptSeq
       AND A.BegDate   <= @BaseDate  
       AND A.EndDate   >= @BaseDate  

     UNION ALL
      
    -- Àç±Í ¸â¹ö(Recursive Member)  
    SELECT A.DeptSeq, A.UppDeptSeq, A.Seq
		  ,A.BegDate, A.EndDate,	A.UMDeptLevel
		  ,A.Remark, A.DispSeq,     CAST(CTE.OrgCd+right('000'+CONVERT(NVARCHAR(3),A.DispSeq),3) AS NVARCHAR(50))  
      FROM _ErrorTable		AS A 
		   JOIN CTE_OrgDept AS CTE ON A.UppDeptSeq = CTE.DeptSeq
     WHERE A.CompanySeq = 1  
       AND A.BegDate   <= @BaseDate  
       AND A.EndDate   >= @BaseDate  
 )  
  
  SELECT * FROM CTE_OrgDept

  RETURN  
  GO
  SELECT * FROM _ErrorTable