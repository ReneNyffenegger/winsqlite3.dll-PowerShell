# 
 #       V e r s i o n   0 . 0 1 
 # 
 #       C o m p a r e   w i t h   h t t p s : / / r e n e n y f f e n e g g e r . c h / n o t e s / d e v e l o p m e n t / d a t a b a s e s / S Q L i t e / V B A / i n d e x 
 # 
 
 s e t - s t r i c t M o d e   - v e r s i o n   2 
 
 a d d - t y p e   - t y p e D e f i n i t i o n   @ " 
 u s i n g   S y s t e m ; 
 u s i n g   S y s t e m . R u n t i m e . I n t e r o p S e r v i c e s ; 
 
 p u b l i c   s t a t i c   p a r t i a l   c l a s s   s q l i t e   { 
 
       p u b l i c   c o n s t   I n t 3 2   O K                           =       0 ; 
       p u b l i c   c o n s t   I n t 3 2   E R R O R                     =       1 ; 
       p u b l i c   c o n s t   I n t 3 2   B U S Y                       =       5 ; 
       p u b l i c   c o n s t   I n t 3 2   M I S U S E                   =     2 1 ;   / /     S Q L i t e   i n t e r f a c e   w a s   u s e d   i n   a   u n d e f i n e d / u n s u p p o r t e d   w a y   ( i . e .   u s i n g   p r e p a r e d   s t a t e m e n t   a f t e r   f i n a l i z i n g   i t ) 
       p u b l i c   c o n s t   I n t 3 2   R O W                         =   1 0 0 ;   / /     s q l i t e 3 _ s t e p ( )   h a s   a n o t h e r   r o w   r e a d y 
       p u b l i c   c o n s t   I n t 3 2   D O N E                       =   1 0 1 ;   / /     s q l i t e 3 _ s t e p ( )   h a s   f i n i s h e d   e x e c u t i n g 
 
       p u b l i c   c o n s t   I n t 3 2   I N T E G E R                 =     1 ; 
       p u b l i c   c o n s t   I n t 3 2   F L O A T                     =     2 ; 
       p u b l i c   c o n s t   I n t 3 2   T E X T                       =     3 ; 
       p u b l i c   c o n s t   I n t 3 2   B L O B                       =     4 ; 
       p u b l i c   c o n s t   I n t 3 2   N U L L                       =     5 ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ o p e n " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   o p e n ( 
           / /       [ M a r s h a l A s ( U n m a n a g e d T y p e . L P S t r ) ] 
                       S t r i n g   z F i l e n a m e , 
               r e f   I n t P t r   p p D B               / /   d b   h a n d l e 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ e x e c " ,   C h a r S e t = C h a r S e t . A n s i ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   e x e c   ( 
                       I n t P t r   d b             ,         / *   A n   o p e n   d a t a b a s e                                                                                               * / 
                       S t r i n g   s q l           ,         / *   S Q L   t o   b e   e v a l u a t e d                                                                                         * / 
                       I n t P t r   c a l l b a c k ,         / *   i n t   ( * c a l l b a c k ) ( v o i d * , i n t , c h a r * * , c h a r * * )   - -   C a l l b a c k   f u n c t i o n     * / 
                       I n t P t r   c b 1 s t A r g ,         / *   1 s t   a r g u m e n t   t o   c a l l b a c k                                                                               * / 
               r e f   S t r i n g   e r r M s g               / *   E r r o r   m s g   w r i t t e n   h e r e     (   c h a r   * * e r r m s g )                                               * / 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ e r r m s g "   ,   C h a r S e t = C h a r S e t . A n s i ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   e r r m s g   ( 
                       I n t P t r         d b 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ p r e p a r e _ v 2 " ,   C h a r S e t = C h a r S e t . A n s i ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   p r e p a r e _ v 2   ( 
                       I n t P t r   d b             ,           / *   D a t a b a s e   h a n d l e                                                                                                     * / 
                       S t r i n g   z S q l         ,           / *   S Q L   s t a t e m e n t ,   U T F - 8   e n c o d e d                                                                           * / 
                       I n t P t r   n B y t e       ,           / *   M a x i m u m   l e n g t h   o f   z S q l   i n   b y t e s .                                                                   * / 
             r e f     I n t P t r   s q l i t e 3 _ s t m t ,   / *   i n t   * * p p S t m t   - -   O U T :   S t a t e m e n t   h a n d l e                                                         * / 
                       I n t P t r   p z T a i l                 / *     c o n s t   c h a r   * * p z T a i l     - -     O U T :   P o i n t e r   t o   u n u s e d   p o r t i o n   o f   z S q l   * / 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ b i n d _ i n t " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   b i n d _ i n t ( 
                       I n t P t r                       s t m t , 
                       I n t P t r   / *   i n t   * /   i n d e x , 
                       I n t P t r   / *   i n t   * /   v a l u e ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ b i n d _ t e x t " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   b i n d _ t e x t ( 
                       I n t P t r         s t m t , 
                       I n t P t r         i n d e x , 
 / /                 [ M a r s h a l A s ( U n m a n a g e d T y p e . L P S t r ) ] 
                       I n t P t r         v a l u e   ,   / *   c o n s t   c h a r *                                     * / 
                       I n t P t r         x           ,   / *   W h a t   d o e s   t h i s   p a r a m e t e r   d o ?   * / 
                       I n t P t r         y               / *   v o i d ( * ) ( v o i d * )                               * / 
           ) ; 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ b i n d _ n u l l " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   b i n d _ n u l l   ( 
                       I n t P t r         s t m t , 
                       I n t P t r         i n d e x 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ s t e p " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   s t e p   ( 
                       I n t P t r         s t m t 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ r e s e t " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   r e s e t   ( 
                       I n t P t r         s t m t 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ c o l u m n _ t y p e " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   c o l u m n _ t y p e   ( 
                         I n t P t r       s t m t , 
                         I n t P t r       i n d e x 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ c o l u m n _ d o u b l e " ) ] 
         p u b l i c   s t a t i c   e x t e r n   D o u b l e   c o l u m n _ d o u b l e   ( 
                         I n t P t r       s t m t , 
                         I n t P t r       i n d e x 
       ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ c o l u m n _ i n t " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   c o l u m n _ i n t ( 
                         I n t P t r       s t m t , 
                         I n t P t r       i n d e x 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ c o l u m n _ t e x t " 
           ,   C h a r S e t = C h a r S e t . A n s i 
         ) ] 
 / /   [ r e t u r n :   M a r s h a l A s ( U n m a n a g e d T y p e . L P S t r ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   c o l u m n _ t e x t   ( 
                         I n t P t r       s t m t , 
                         I n t P t r       i n d e x 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ f i n a l i z e " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   f i n a l i z e   ( 
                       I n t P t r         s t m t 
         ) ; 
 
       [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ,   E n t r y P o i n t = " s q l i t e 3 _ c l o s e " ) ] 
         p u b l i c   s t a t i c   e x t e r n   I n t P t r   c l o s e   ( 
                       I n t P t r         d b 
         ) ; 
 
 
 / /   [ D l l I m p o r t ( " w i n s q l i t e 3 . d l l " ) ] 
 / /       p u b l i c   s t a t i c   e x t e r n   I n t P t r   s q l i t e 3 _ c l e a r _ b i n d i n g s ( 
 / /                     I n t P t r         s t m t 
 / /     ) ; 
 
 } 
 " @ 
 