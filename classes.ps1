s e t - s t r i c t M o d e   - v e r s i o n   2 
 
 f u n c t i o n   c h a r P t r T o S t r i n g ( [ I n t P t r ] $ c h a r P t r )   { 
       [ O u t p u t T y p e ( [ S t r i n g ] ) ] 
   # 
   #   C r e a t e   a   . N E T / P o w e r S h e l l   s t r i n g   f r o m   t h e   b y t e s 
   #   t h a t   a r e   p o i n t e d   a t   b y   $ c h a r P t r 
   # 
       [ I n t P t r ]   $ i   =   0 
 
       $ s t r B   =   n e w - o b j e c t   T e x t . S t r i n g B u i l d e r 
       w h i l e   (   [ R u n t i m e . I n t e r o p S e r v i c e s . M a r s h a l ] : : R e a d B y t e ( $ c h a r P t r ,   $ i )   - g t   0   )   { 
             $ n u l l   =   $ s t r B . A p p e n d (   [ R u n t i m e . I n t e r o p S e r v i c e s . M a r s h a l ] : : R e a d B y t e ( $ c h a r P t r ,   $ i )   - a s   [ C h a r ]   ) 
             $ i = $ i + 1 
       } 
       r e t u r n   $ s t r B . T o S t r i n g ( ) 
 } 
 
 f u n c t i o n   s t r T o C h a r P t r ( [ S t r i n g ]   $ s t r )   { 
       [ O u t p u t T y p e ( [ I n t P t r ] ) ] 
   # 
   #   C r e a t e   a   U T F - 8   b y t e   a r r a y   o n   t h e   u n m a n a g e d   h e a p 
   #   f r o m   $ s t r   a n d   r e t u r n   a   p o i n t e r   t o   t h a t   a r r a y 
   # 
 
       [ B y t e [ ] ]   $ b y t e s             =   [ S y s t e m . T e x t . E n c o d i n g ] : : U T F 8 . G e t B y t e s ( $ s t r ) ; 
 
   #   Z e r o   t e r m i n a t e d   b y t e s 
       [ B y t e [ ] ]   $ b y t e s 0         =   n e w - o b j e c t   ' B y t e [ ] '   ( $ b y t e s . L e n g t h   +   1 ) 
       [ A r r a y ] : : C o p y ( $ b y t e s ,   $ b y t e s 0 ,   $ b y t e s . L e n g t h ) 
 
       [ I n t P t r ]   $ h e a p P t r   =   [ R u n t i m e . I n t e r o p S e r v i c e s . M a r s h a l ] : : A l l o c H G l o b a l ( $ b y t e s 0 . L e n g t h ) ; 
       [ R u n t i m e . I n t e r o p S e r v i c e s . M a r s h a l ] : : C o p y ( $ b y t e s 0 ,   0 ,   $ h e a p P t r ,   $ b y t e s 0 . L e n g t h ) ; 
 
       r e t u r n   $ h e a p P t r 
 } 
 
 c l a s s   s q l i t e D B   { 
 
       [ I n t P t r ]   h i d d e n   $ d b 
 
       s q l i t e D B ( 
             [ s t r i n g ]   $ d b F i l e N a m e , 
             [ b o o l     ]   $ n e w 
       )   { 
 
       i f   ( $ n e w )   { 
             i f   ( t e s t - p a t h   $ d b F i l e N a m e )   { 
                   r e m o v e - i t e m   $ d b F i l e N a m e   #   D o n ' t   u s e   ' - e r r o r A c t i o n   i g n o r e '   t o   g e t   e r r o r   m e s s a g e 
             } 
       } 
 
       $ t h i s . o p e n ( $ d b F i l e N a m e ,   $ n e w ) 
 
       } 
 
       s q l i t e D B ( 
             [ s t r i n g ]   $ d b F i l e N a m e 
       )   { 
             $ t h i s . o p e n ( $ d b F i l e N a m e ,   $ f a l s e ) 
       } 
 
       [ v o i d ]   h i d d e n   o p e n ( 
             [ s t r i n g ]   $ d b F i l e N a m e , 
             [ b o o l     ]   $ n e w 
       )   { 
         # 
         #   T h i s   m e t h o d   i s   n o t   i n t e n d e d   t o   b e   c a l l e d   d i r e c t l y ,   b u t 
         #   r a t h e r   i n d i r e c t l y   v i a   t h e   c l a s s ' s   c o n s t r u c t o r . 
         #   T h i s   c o n s t r u c t   i s   n e c e s s a r y   b e c a u s e   P o w e r S h e l l   d o e s   n o t   a l l o w   f o r 
         #   c o n s t r u c t o r   c h a i n i n g . 
         #       S e e   h t t p s : / / s t a c k o v e r f l o w . c o m / a / 4 4 4 1 4 5 1 3 
         #   T h i s   i s   a l s o   t h e   r e a s o n   w h y   t h i s   m e t h o d   i s   d e c l a r e d   h i d d e n . 
         # 
 
       [ I n t P t r ]   $ d b _   =   0 
       $ r e s   =   [ s q l i t e ] : : o p e n ( $ d b F i l e N a m e ,   [ r e f ]   $ d b _ ) 
       $ t h i s . d b   =   $ d b _ 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   t h r o w   " C o u l d   n o t   o p e n   $ d b F i l e N a m e " 
             } 
       } 
 
 
       [ v o i d ]   e x e c ( 
             [ S t r i n g ] $ s q l 
       )   { 
 
           [ S t r i n g ] $ e r r M s g   =   ' ' 
             $ r e s   =   [ s q l i t e ] : : e x e c ( $ t h i s . d b ,   $ s q l ,   0 ,   0 ,   [ r e f ]   $ e r r M s g ) 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   w r i t e - w a r n i n g   " s q l i t e E x e c :   $ e r r M s g " 
             } 
 
       } 
 
       [ s q l i t e S t m t ]   p r e p a r e S t m t ( 
             [ S t r i n g ]   $ s q l 
       )   { 
 
             $ s t m t   =   [ s q l i t e S t m t ] : : n e w ( $ t h i s ) 
             [ I n t P t r ]   $ h a n d l e _   =   0 
             $ r e s   =   [ s q l i t e ] : : p r e p a r e _ v 2 ( $ t h i s . d b ,   $ s q l ,   - 1 ,   [ r e f ]   $ h a n d l e _ ,   0 ) 
             $ s t m t . h a n d l e   =   $ h a n d l e _ 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   w r i t e - w a r n i n g   " p r e p a r e S t m t :   s q l i t e 3 _ p r e p a r e   f a i l e d ,   r e s   =   $ r e s " 
                   w r i t e - w a r n i n g   ( $ t h i s . e r r m s g ( ) ) 
             } 
             r e t u r n   $ s t m t 
       } 
 
 
       [ v o i d ]   c l o s e ( )   { 
             $ r e s   =   [ s q l i t e ] : : c l o s e ( $ t h i s . d b ) 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
 
                   i f   ( $ r e s   - e q   [ s q l i t e ] : : B U S Y )   { 
                         w r i t e - w a r n i n g   " C l o s e   d a t a b a s e :   d a t a b a s e   i s   b u s y " 
                   } 
                   e l s e   { 
                         w r i t e - w a r n i n g   " C l o s e   d a t a b a s e :   $ r e s " 
                         w r i t e - w a r n i n g   ( $ t h i s . e r r m s g ( ) ) 
                   } 
                   w r i t e - e r r o r   ( $ t h i s . e r r m s g ( ) ) 
                   t h r o w   " C o u l d   n o t   c l o s e   d a t a b a s e " 
             } 
       } 
 
       [ S t r i n g ]   e r r m s g ( )   { 
             r e t u r n   c h a r P t r T o S t r i n g   ( [ s q l i t e ] : : e r r m s g ( $ t h i s . d b ) ) 
       } 
 } 
 
 c l a s s   s q l i t e S t m t   { 
 
       [ I n t P t r     ]   h i d d e n   $ h a n d l e 
       [ s q l i t e D B ]   h i d d e n   $ d b 
 
   # 
   #   P o o r   m a n ' s   m a n a g e m e n t   o f   a l l o c a t e d   m e m o r   o n   t h e   h e a p . 
   #   T h i s   i s   n e c e s s a r y ( ? )   b e c a u s e   t h e   S Q L i t e   s t a t e m e n t   i n t e r f a c e   e x p e c t s 
   #   a   c h a r *   p o i n t e r   w h e n   b i n d i n g   t e x t .   T h i s   c h a r *   p o i n t e r   m u s t 
   #   s t i l l   b e   v a l i d   a t   t h e   t i m e   w h e n   t h e   s t a t e m e n t   i s   e x e c u t e d . 
   #   I   w a s   u n a b l e   t o   a c h i e v e   t h a t   w i t h o u t   a l l o c a t i n g   a   c o p y   o f   t h e 
   #   s t r i n g ' s   b y t e s   o n   t h e   h e a p   a n d   t h e n   r e l e a s e   i t   a f t e r   t h e 
   #   s t a t e m e n t - s t e p   i s   e x e c u t e d . 
   #   T h e r e   a r e   p o s s i b l y   m o r e   e l e g a n t   w a y s   t o   a c h i e v e   t h i s ,   w h o   k n o w s ? 
   # 
       [ I n t P t r [ ] ]   h i d d e n   $ h e a p A l l o c s 
 
       s q l i t e S t m t ( [ s q l i t e D B ]   $ d b _ )   { 
             $ t h i s . d b                   =   $ d b _ 
             $ t h i s . h a n d l e           =       0 
             $ t h i s . h e a p A l l o c s   =   @ ( ) 
       } 
 
       [ v o i d ]   b i n d ( 
             [ I n t       ]   $ i n d e x , 
             [ O b j e c t ]   $ v a l u e 
       )   { 
 
             i f   ( $ v a l u e   - e q   $ n u l l )   { 
                   $ r e s   =   [ s q l i t e ] : : b i n d _ n u l l ( $ t h i s . h a n d l e ,   $ i n d e x ) 
             } 
             e l s e i f   ( $ v a l u e   - i s   [ S t r i n g ] )   { 
                   [ I n t P t r ]   $ h e a p P t r   =   s t r T o C h a r P t r ( $ v a l u e ) 
                   $ r e s   =   [ s q l i t e ] : : b i n d _ t e x t ( $ t h i s . h a n d l e ,   $ i n d e x ,   $ h e a p P t r ,   $ v a l u e . l e n g t h ,   0 ) 
 
               # 
               #   K e e p   t r a c k   o f   a l l o c a t i o n s   o n   h e a p ,   f r e e   l a t e r 
               # 
                   $ t h i s . h e a p A l l o c s   + =   $ h e a p P t r 
             } 
             e l s e i f   ( $ v a l u e   - i s   [ I n t ] )   { 
                   $ r e s   =   [ s q l i t e ] : : b i n d _ i n t ( $ t h i s . h a n d l e ,   $ i n d e x ,   $ v a l u e ) 
             } 
             e l s e   { 
                   t h r o w   " t y p e   $ ( $ v a l u e . G e t T y p e ( ) )   n o t   ( y e t ? )   s u p p o r t e d " 
             } 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   w r i t e - w a r n i n g   $ t h i s . d b . e r r m s g ( ) 
                   w r i t e - w a r n i n g   " i n d e x :   $ i n d e x ,   v a l u e :   $ v a l u e " 
                   t h r o w   " s q l i t e B i n d :   r e s   =   $ r e s " 
             } 
       } 
 
       [ I n t P t r ]   s t e p ( )   { 
             $ r e s   =   [ s q l i t e ] : : s t e p ( $ t h i s . h a n d l e ) 
 
       #     i f   ( $ r e s   - n e   [ s q l i t e ] : : D O N E )   { 
       #           t h r o w   " s q l i t e S t e p :   r e s   =   $ r e s " 
       #     } 
 
             f o r e a c h   ( $ p   i n   $ t h i s . h e a p A l l o c s )   { 
                   [ I n t P t r ]   $ r e t P t r   =   [ R u n t i m e . I n t e r o p S e r v i c e s . M a r s h a l ] : : F r e e H G l o b a l ( $ p ) ; 
             } 
 
           # 
           #   F r e e   t h e   a l l o c ' d   m e m o r y   t h a t   w a s   n e c e s s a r y   t o   p a s s 
           #   s t r i n g s   t o   t h e   s q l i t e   e n g i n e : 
           # 
             $ t h i s . h e a p A l l o c s   =   @ ( ) 
 
             r e t u r n   $ r e s 
       } 
 
       [ v o i d ]   r e s e t ( )   { 
             $ r e s   =   [ s q l i t e ] : : r e s e t ( $ t h i s . h a n d l e ) 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   t h r o w   " s q l i t e B i n d :   r e s   =   $ r e s " 
             } 
       } 
 
       [ o b j e c t ]   c o l ( 
                   [ I n t ]   $ i n d e x 
       )   { 
 
             $ c o l T y p e   = [ s q l i t e ] : : c o l u m n _ t y p e ( $ t h i s . h a n d l e ,   $ i n d e x ) 
             s w i t c h   ( $ c o l T y p e )   { 
 
                   ( [ s q l i t e ] : : I N T E G E R )   { 
                         r e t u r n   [ s q l i t e ] : : c o l u m n _ i n t ( $ t h i s . h a n d l e ,   $ i n d e x ) 
                   } 
                   ( [ s q l i t e ] : : F L O A T )       { 
                         r e t u r n   [ s q l i t e ] : : c o l u m n _ f l o a t ( $ t h i s . h a n d l e ,   $ i n d e x ) 
                   } 
                   ( [ s q l i t e ] : : T E X T )         { 
                         [ I n t P t r ]   $ c h a r P t r   =   [ s q l i t e ] : : c o l u m n _ t e x t ( $ t h i s . h a n d l e ,   $ i n d e x ) 
                         r e t u r n   c h a r P t r T o S t r i n g   $ c h a r P t r 
                   } 
                   ( [ s q l i t e ] : : B L O B )       { 
                         r e t u r n   " T O D O :   b l o b " 
                   } 
                   ( [ s q l i t e ] : : N U L L )         { 
                         r e t u r n   $ n u l l 
                   } 
                   d e f a u l t                       { 
                         t h r o w   " T h i s   s h o u l d   n o t   b e   p o s s i b l e   $ ( [ s q l i t e ] : : s q l i t e 3 _ c o l u m n _ t y p e ( $ t h i s . h a n d l e ,   $ i n d e x ) ) " 
                   } 
             } 
             r e t u r n   $ n u l l 
       } 
 
       [ v o i d ]   b i n d A r r a y S t e p R e s e t ( [ o b j e c t [ ] ]   $ c o l s )   { 
             $ c o l N o   =   1 
             f o r e a c h   ( $ c o l   i n   $ c o l s )   { 
                     $ t h i s . b i n d ( $ c o l N o ,   $ c o l ) 
                     $ c o l N o   + + 
             } 
             # $ n u l l   =   s q l i t e S t e p     $ s t m t 
             $ t h i s . s t e p ( ) 
             $ t h i s . r e s e t ( ) 
       } 
 
       [ v o i d ]   f i n a l i z e ( )   { 
             $ r e s   =   [ s q l i t e ] : : f i n a l i z e ( $ t h i s . h a n d l e ) 
 
             i f   ( $ r e s   - n e   [ s q l i t e ] : : O K )   { 
                   t h r o w   " s q l i t e F i n a l i z e :   r e s   =   $ r e s " 
             } 
       } 
 } 
 