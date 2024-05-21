.code
;-----------------AI-------------------
isPileEmpty MACRO pileTaille,result
    LOCAL empty, notEmpty,endPileEmpty
    CMP pileTaille, 0
    JE empty
        JMP notEmpty
    empty:
        MOV AL, 1
        MOV result,AL
        JMP endPileEmpty
    notEmpty:
        MOV AL, 0
        MOV result,AL
    endPileEmpty:
ENDM
;--------------------------------------
pushPile MACRO pileTaille,node,weight
    MOV AX,0
    MOV AH,weight
    MOV AL,node
    PUSH AX
    INC pileTaille
ENDM
;--------------------------------------
popPile MACRO pileTaille,node,weight
    MOV AX,0
    POP AX
    MOV node,AL
    MOV weight,AH
    DEC pileTaille
ENDM

;--------------------------------------
getPawnQueen MACRO board,node,turn,weightTmp
    LOCAL queen,pawn,next,next2,endGetPawn
    MOV weightTmp,0
    
    MOV BX,0
    MOV BL,node
    DEC BL
    queen:
    MOV AL,Board[BX]
    CMP AL,'B'
    JNE next
    MOV weightTmp,10
    JMP endGetPawn
    next:
    MOV AL,Board[BX]
    CMP AL,'W'
    JNE pawn
    MOV weightTmp,10
    JMP endGetPawn

    pawn:
    MOV AL,Board[BX]
    CMP AL,'b'
    JNE next2
    MOV weightTmp,1
    JMP endGetPawn

    next2:
    CMP Board[BX],'w'
    MOV weightTmp,1

    endGetPawn:
ENDM
;--------------------------------------
copyPath MACRO maxpath,path,pathTaille
    LOCAL boucle
    LEA SI,maxpath
    LEA DI,path
    XOR CX,CX
    MOV CL,pathTaille

    boucle:
        MOV AL,[DI]
        MOV [SI],AL
        INC SI
        INC DI

        LOOP boucle
ENDM
;--------------------------------------
preOrder MACRO pileTaille,root,weight,path
    LOCAL bouclePreOrder,restofcode,rightPre,rest1,left,rest2,feuilles,estFeuilles,cond1,cond2,last,endPreOrder,change,isPromoted
    MOV weight,0
    pushPile pileTaille,root,weight
    MOV pathSizeArrayIndex,1
    MOV pathSizeArray[0],0
    bouclePreOrder:
            isPileEmpty pileTaille,AL
            CMP AL,1
            JNE restofcode
            JMP endPreOrder
        restofcode:
            
            popPile pileTaille,root,weight
            
            MOV BX,0
            DEC pathSizeArrayIndex
            MOV BL,pathSizeArrayIndex
            MOV AL,pathSizeArray[BX]
            MOV pathTaille,AL
            MOV BL,pathTaille
            MOV BH,0
            MOV AL,root
            MOV path[BX],AL
            ADD pathTaille,1
            get_column root , jAI
            get_row root ,  iAI
            ;printBoardWithOffset board, 000fh, 0, 0
            XOR BX,BX
            MOV BL,root
            DEC BL
            MOV AL,board[BX]
            MOV tmp,AL
            MOV AL,turn
            MOV board[BX],AL
            show_path board,iAI,jAI,turn,path1,path2,pawn_position,makla1,makla2
            XOR BX,BX
            MOV BL,root
            DEC BL
            MOV AL,tmp
            MOV board[BX],AL
        
            rightPre:
                CMP makla2,-1
                JNE rest1
                JMP left
                rest1:
                
                getPawnQueen board,makla2,turn,weightTmp
                MOV AL,weight
                ADD weightTmp,AL
                pushPile pileTaille,path2,weightTmp
                MOV BX,0
                MOV BL,pathSizeArrayIndex
                MOV AL,pathTaille
                MOV pathSizeArray[BX],AL
                inc pathSizeArrayIndex
    
            left:
                CMP makla1,-1
                JNE rest2
                JMP feuilles
                rest2:
                
                getPawnQueen board,makla1,turn,weightTmp
                MOV AL,weight
                ADD weightTmp,AL
                pushPile pileTaille,path1,weightTmp
                MOV BX,0
                MOV BL,pathSizeArrayIndex
                MOV AL,pathTaille
                MOV pathSizeArray[BX],AL
                inc pathSizeArrayIndex
            
            estFeuilles:
                cond1:
                    CMP makla2,-1
                    JE cond2
                    JMP bouclePreOrder
                cond2:
                    CMP makla1,-1
                    JE feuilles
                    JMP bouclePreOrder
                

    
            feuilles:
                get_row root ,iAI
                CMP iAI,0
                JNE bturn
                JMP isPromoted
                bturn:
                get_row root ,iAI
                CMP iAI,9
                JNE last
                
                isPromoted:
                ADD weight,9
                last:
                MOV AL, weight
                CMP AL, maxWeight
                JA change
                JMP bouclePreOrder
                change:
                    MOV AL,weight
                    MOV maxWeight,AL
                    copyPath maxpath,path,pathTaille
                    
                JMP bouclePreOrder
    endPreOrder:
ENDM
;--------------------------------------
 pionWeight MACRO root,weight
     LOCAL path1Ver,path2Ver,path3Ver,changeP,endPionWeight   
     
           get_column root , jAI
           get_row root ,  iAI
           show_path board,iAI,jAI,turn,path1,path2,pawn_position,makla1,makla2
           
           path1Ver:
            pionPromoted path1,iAI,al
            CMP al,1
            JNE path2Ver
            MOV weight,9
            JMP path3Ver
            
           path2Ver:
            pionPromoted path2,iAI,al
            CMP al,1
            JNE path3Ver
            MOV weight,9
            
           path3Ver:  
           MOV AL, weight
           CMP AL, maxWeight
           JA changeP
           JMP endPionWeight
              changeP:
                 MOV AL,weight
                 MOV maxWeight,AL
                 
           endPionWeight:
 ENDM   
;--------------------------------------
pionPromoted Macro num,turn,result
    LOCAL blackSide,restB,whiteSide,endPionPromoted
    
    Mov result,0
    blackSide:
        CMP turn,'b'
        JE restB
        JMP whiteSide
        
        restB:
        get_row num ,i
        CMP i,9
        JNE endPionPromoted
        MOV result,1
        
        
        JMP endPionPromoted
    whiteSide:
        
        get_row num ,i
        CMP i,0
        JNE endPionPromoted
        MOV result,1
        
    endPionPromoted:
    
ENDM
;--------------------------------------
enemyMove MACRO board, turn, maklaSif , weight , maxWeight , path , bestPath 
    LOCAL indirectEnemyMove,MaklaSifPart,enemyRest,directEnemyMove,Before,enemyRestP,finEnemyMove 
    
    MOV maxWeight,0
    show_moves  board, indMoves, directMoves
    MOV indice,0
    indirectEnemyMove:   
        MOV BX,0
        MOV BL,indice
        MOV AL,indMoves[BX]
        CMP AL,0
        JNE enemyRest
        JMP Before
        enemyRest:
        
            MOV AL,indMoves[BX]
            MOV root,AL
            preOrder pileTaille,root,weight,path 
        
            INC indice
        JMP indirectEnemyMove 

        MaklaSifPart:
        CMP maklaSif,1
        JNE Before
        JMP finEnemyMove
    
    
    Before:
    
    MOV indice,0
    directEnemyMove:
           
            MOV BX,0
            MOV BL,indice
            MOV AL,directMoves[BX]
            CMP AL,0
            JNE enemyRestP
            JMP finEnemyMove
            enemyRestP:
               
               MOV weight,0
               MOV BX,0
               MOV BL,indice
               MOV AL,directMoves[BX]
               MOV root,AL
               pionWeight root,weight
    
            INC indice                                
            JMP directEnemyMove

    finEnemyMove:


ENDM





;--------------------------------------
aipreOrder MACRO
    LOCAL boucleaiPreOrder,restofcode,rightPre,rest1,left,rest2,feuilles,estFeuilles,cond1,cond2,last,endaiPreOrder,change,isPromoted
    MOV aiweight,0
    pushPile aipileTaille,airoot,aiweight
    MOV aipathSizeArrayIndex,1
    MOV aipathSizeArray[0],0
    boucleaiPreOrder:
            isPileEmpty aipileTaille,AL
            CMP AL,1
            JNE restofcode
            JMP endaiPreOrder
        restofcode:
            
            popPile aipileTaille,airoot,aiweight
            
            MOV BX,0
            DEC aipathSizeArrayIndex
            MOV BL,aipathSizeArrayIndex
            MOV AL,aipathSizeArray[BX]
            MOV aipathTaille,AL
            MOV BL,aipathTaille
            MOV BH,0
            MOV AL,airoot
            MOV aipath[BX],AL
            ADD aipathTaille,1
            get_column airoot , jAI2
            get_row airoot ,  iAI1
            ;printBoardWithOffset board, 000fh, 0, 0
            XOR BX,BX
            MOV BL,airoot
            DEC BL
            MOV AL,board[BX]
            MOV aitmp,AL
            MOV AL,aiturn
            MOV board[BX],AL
            show_path board,iAI1,jAI2,aiturn,aipath1,aipath2,pawn_position,aimakla1,aimakla2
            XOR BX,BX
            MOV BL,airoot
            DEC BL
            MOV AL,aitmp
            MOV board[BX],AL
        
            rightPre:
                CMP aimakla2,-1
                JNE rest1
                JMP left
                rest1:
                
                getPawnQueen board,aimakla2,aiturn,aiweightaiTmp
                MOV AL,aiweight
                ADD aiweightaiTmp,AL
                pushPile aipileTaille,aipath2,aiweightaiTmp
                MOV BX,0
                MOV BL,aipathSizeArrayIndex
                MOV AL,aipathTaille
                MOV aipathSizeArray[BX],AL
                inc aipathSizeArrayIndex
    
            left:
                CMP aimakla1,-1
                JNE rest2
                JMP feuilles
                rest2:
                
                getPawnQueen board,aimakla1,aiturn,aiweightaiTmp
                MOV AL,aiweight
                ADD aiweightaiTmp,AL
                pushPile aipileTaille,aipath1,aiweightaiTmp
                MOV BX,0
                MOV BL,aipathSizeArrayIndex
                MOV AL,aipathTaille
                MOV aipathSizeArray[BX],AL
                inc aipathSizeArrayIndex
            
            estFeuilles:
                cond1:
                    CMP aimakla2,-1
                    JE cond2
                    JMP boucleaiPreOrder
                cond2:
                    CMP aimakla1,-1
                    JE feuilles
                    JMP boucleaiPreOrder
                

    
            feuilles:
                get_row airoot ,iAI1
                CMP iAI1,0
                JNE baiturn
                JMP isPromoted
                baiturn:
                get_row airoot ,iAI1
                CMP iAI1,9
                JNE last
                
                isPromoted:
                ADD aiweight,9
                last:
                copyBoard board,board2
                MakeMoveAI board2,path
                enemyMove board,turn , maklaSif , weight , maxWeight , path , bestPath
                MOV AL, aiweight
                SUB AL, maxWeight
                
                MOV aiweight,AL
                CMP AL, maxaiWeight
                JA change
                JMP boucleaiPreOrder
                change:
                    MOV AL,aiweight
                    MOV maxaiWeight,AL
                    copyPath maxaipath,aipath,aipathTaille
                    
                JMP boucleaiPreOrder
    endaiPreOrder:
ENDM
;--------------------------------------
 pionaiWeight MACRO airoot,aiweight
     LOCAL aipath1Ver,aipath2Ver,aipath3Ver,changeP,endPionaiWeight   
     
           get_column airoot , jAI2
           get_row airoot ,  iAI1
           show_path board,iAI1,jAI2,aiturn,aipath1,aipath2,pawn_position,aimakla1,aimakla2
           
           aipath1Ver:
            pionPromoted aipath1,iAI1,al
            CMP al,1
            JNE aipath2Ver
            MOV aiweight,9
            JMP aipath3Ver
            
           aipath2Ver:
            pionPromoted aipath2,iAI1,al
            CMP al,1
            JNE aipath3Ver
            MOV aiweight,9
            
           aipath3Ver:  
           MOV AL, aiweight
           CMP AL, maxaiWeight
           JA changeP
           JMP endPionaiWeight
              changeP:
                 MOV AL,aiweight
                 MOV maxaiWeight,AL
                 
           endPionaiWeight:
 ENDM   

;-------------------------------------- 
MakeMoveAI MACRO board,path
   LOCAL boucle22,finMove
    boucle22:
        MOV BX,0
        MOV al,path[bx]
        INC BX
        MOV ah,path[bx]
        CMP ah,NULL
        je finMove
        MOV n1,al
        MOV n2,ah
        
        MakeAMove board,n1,n2,AIturn
        
        JMP boucle22                
    finMove:
ENDM
;--------------------------------------
aiMove MACRO board, aiturn, maklaSif , aiweight , maxaiWeight , aipath , bestaiPath 
    LOCAL indirectEnemyMove,MaklaSifPart,enemyRest,directEnemyMove,Before,enemyRestP,finEnemyMove 
    
    MOV maxaiWeight,0
    show_moves  board, aiindMoves, aidirectMoves
    MOV aiindice,0
    indirectEnemyMove:   
        MOV BX,0
        MOV BL,aiindice
        MOV AL,aiindMoves[BX]
        CMP AL,0
        JNE enemyRest
        JMP Before
        enemyRest:
        
            MOV AL,aiindMoves[BX]
            MOV airoot,AL
            aipreOrder aipileTaille,airoot,aiweight,aipath 
        
            INC aiindice
        JMP indirectEnemyMove 

        MaklaSifPart:
        CMP maklaSif,1
        JNE Before
        JMP finEnemyMove
    
    
    Before:
    
    MOV aiindice,0
    directEnemyMove:
           
            MOV BX,0
            MOV BL,aiindice
            MOV AL,aidirectMoves[BX]
            CMP AL,0
            JNE enemyRestP
            JMP finEnemyMove
            enemyRestP:
               
               MOV aiweight,0
               MOV BX,0
               MOV BL,aiindice
               MOV AL,aidirectMoves[BX]
               MOV airoot,AL
               pionaiWeight airoot,aiweight
    
            INC aiindice                                
            JMP directEnemyMove

    finEnemyMove:


ENDM 
    

MakeAMove Macro board,n1,n2,PColor
        LOCAL 
    

ENDM


copyBoard MACRO board,board2
    LOCAL boucle,finCopy
    MOV BX,49
    boucle:
           CMP BX,-1
           JNE rest
           JMP finCopy
           rest:
           
           MOV al,board[BX]
           MOV board2,al
           
           DEC BX
           JMP boucle
    finCopy
      
        
ENDM