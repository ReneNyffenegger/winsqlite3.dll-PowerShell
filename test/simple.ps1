s e t - s t r i c t M o d e   - v e r s i o n   2 
 
 [ s q l i t e D B ]   $ d b   =   [ s q l i t e D B ] : : n e w ( " $ ( $ p w d ) \ t h e . d b " ,   $ t r u e ) 
 
 # 
 #     $ d b . e x e c   w r i t e s   w a r n i n g   i f   s t a t e m e n t   h a s   e r r o r . 
 # 
 $ d b . e x e c ( ' c r e a t e   t a b l e   t a b ( f o o ,   b a r ,   b a z '   )   #   i n c o m p l e t e   i n p u t 
 $ d b . e x e c ( ' c r e a t e   t a b l e   t a b ( f o o ,   b a r ,   b a z ) ' ) 
 $ d b . e x e c ( ' c r e a t e   t a b l e   t a b ( f o o ,   b a r ,   b a z ) ' )   #   t a b l e   t a b   a l r e a d y   e x i s t s 
 
 [ s q l i t e S t m t ]   $ s t m t   =   $ d b . p r e p a r e S t m t ( ' i n s e r t   i n t o   t a b   v a l u e s ( ? ,   ? ,   ? ) ' ) 
 
 $ s t m t . b i n d ( 1 ,     4   ) 
 $ s t m t . b i n d ( 2 ,   ' A ' ) 
 $ s t m t . b i n d ( 3 ,     3 3 3 ) 
 $ n u l l   =   $ s t m t . s t e p ( ) 
 
 $ s t m t . r e s e t ( ) 
 $ s t m t . b i n d ( 1 ,     8 8 ) 
 $ s t m t . b i n d ( 2 ,   ' B B ' ) 
 $ s t m t . b i n d ( 3 ,     $ n u l l ) 
 $ n u l l   =   $ s t m t . s t e p ( ) 
 
 $ s t m t . r e s e t ( ) 
 $ s t m t . b i n d ( 1 ,     1 1 1 ) 
 $ s t m t . b i n d ( 2 ,   ' I I I ' ) 
 $ s t m t . b i n d ( 3 ,     4 2 ) 
 $ n u l l   =   $ s t m t . s t e p ( ) 
 
 $ s t m t . r e s e t ( ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   (   4 4     , ' A A '     ,     9 9   ) ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   ( 4 4 4   ,   ' A A A '   ,   9 9 9   ) ) 
 
 $ d b . e x e c ( ' b e g i n   t r a n s a c t i o n ' ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   ( 5 5 5   ,   ' S S S '   ,   ' t r x ' )   ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   ( 3 3 3   ,   ' E E E '   ,   ' t r x ' )   ) 
 $ d b . e x e c ( ' c o m m i t ' ) 
 
 $ d b . e x e c ( ' b e g i n   t r a n s a c t i o n ' ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   ( 5 0 0   ,   ' S o o '   ,   ' t r x ! ' )   ) 
 $ s t m t . b i n d A r r a y S t e p R e s e t (   ( 3 0 0   ,   ' E o o '   ,   ' t r x ! ' )   ) 
 $ d b . e x e c ( ' r o l l b a c k ' ) 
 
 $ s t m t . f i n a l i z e ( ) 
 
 $ s t m t   =   $ d b . p r e p a r e S t m t ( ' s e l e c t   *   f r o m   t a b   w h e r e   f o o   >   ?   o r d e r   b y   f o o ' ) 
 $ s t m t . B i n d ( 1 ,   5 0 ) 
 
 w h i l e   (   $ s t m t . s t e p ( )     - n e   [ s q l i t e ] : : D O N E   )   { 
       e c h o   " $ ( $ s t m t . c o l ( 0 ) )   |   $ ( $ s t m t . c o l ( 1 ) )   |   $ ( $ s t m t . c o l ( 2 ) ) " 
 } 
 
 $ s t m t . f i n a l i z e ( ) 
 $ d b . c l o s e ( ) 
 