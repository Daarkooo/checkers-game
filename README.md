# Documentation du jeu de dames

## Introduction
Ce document fournit un guide complet pour le jeu de dames développé par une équipe de six étudiants de l'Université USTHB, Info Ing L2. Le jeu est implémenté en langage Assembly 8086 et cette version est conçue pour fonctionner sur l'invite de commande. Une version GUI du jeu est également disponible.

## Structure du jeu
Le jeu est structuré autour d'un plateau de 50 cellules, représentant uniquement les cases noires d'un plateau de dames traditionnel 8x8. Chaque cellule peut être dans l'un des trois états :
- '0' pour une cellule vide
- 'b' pour une cellule occupée par un pion noir
- 'w' pour une cellule occupée par un pion blanc

## Macros
Le jeu utilise plusieurs macros pour effectuer diverses opérations. Voici quelques-unes des macros clés :

### find_ligne MACRO n, result
Cette macro retourne la ligne (0-9) d'une cellule donnée. Elle prend en entrée le numéro de la cellule `n` et stocke le résultat dans `result`.

### find_column MACRO n,result
Cette macro retourne la colonne (0-9) d'une cellule donnée. Elle prend en entrée le numéro de la cellule `n` et stocke le résultat dans `result`.

### getNumber MACRO i,j, n
Cette macro retourne le numéro de cellule `N` pour une ligne `i` et une colonne `j` donnée. Si la cellule est blanche, elle retourne 0.

### board_init MACRO board
Cette macro initialise le plateau de jeu. Elle définit les 20 premières cellules à 'b' (représentant les pièces noires), les 10 cellules suivantes à '0' (représentant les cellules vides), et les 20 dernières cellules à 'w' (représentant les pièces blanches).

### CaseColor MACRO i,j
Cette macro détermine la couleur d'une cellule donnée à la ligne `i` et à la colonne `j`. Elle imprime 'blanc' pour une cellule blanche et 'noir' pour une cellule noire.

### getCellState MACRO board, i, j, result,number
Cette macro retourne l'état d'une cellule à la ligne `i` et à la colonne `j` sur le `board`. Elle stocke l'état dans `result` et le numéro de la cellule dans `number`.

### print_char MACRO asciiCode
Cette macro imprime un caractère correspondant à un code ASCII `asciiCode` donné.

### print_string MACRO reference
Cette macro imprime une chaîne de caractères pointée par `reference`.

### print_board MACRO board
Cette macro imprime l'état actuel du `board`.

### effacer macro
Cette macro efface le plateau de jeu.

### pre_deplacement macro i,j,x,y,dep_possible,turn,dame
Cette macro vérifie si un déplacement de la cellule `(i,j)` à la cellule `(x,y)` est possible. Elle stocke le résultat dans `dep_possible`.

### deplacement_pion macro x,y,turn,tableau,board
Cette macro effectue un déplacement de la cellule courante à la cellule `(x,y)` si le déplacement est valide.

### show_path_pion macro i,j,tableau,turn
Cette macro montre tous les déplacements possibles pour un pion à la cellule `(i,j)`.

### show_path_dame macro i,j,tableau,turn
Cette macro montre tous les déplacements possibles pour une dame à la cellule `(i,j)`.

### deplacement_dame macro x,y,tableau
Cette macro effectue un déplacement de la cellule courante de la dame à la cellule `(x,y)` si le déplacement est valide.

### show_path_global macro i,j,sauvegarde,turn,value1,value2
Cette macro montre tous les déplacements possibles pour une pièce (pion ou dame) à la cellule `(i,j)`.

### deplacement_index macro ligne,cologne
Cette macro déplace le curseur à la position `(ligne,cologne)`.

### coolorie macro vall1,vall2,coul,vall3
Cette macro colore une cellule à `(vall1,vall2)` avec la couleur `coul` et la valeur `vall3`.

### init_sauvegarde macro
Cette macro initialise le tableau `sauvegarde`.

### selectioner_parametre macro  val,tmp3,tmp4
Cette macro sélectionne un paramètre en fonction de l'entrée de l'utilisateur.

## Comment jouer
Pour jouer au jeu, vous devez suivre les invites sur la ligne de commande. Vous serez invité à entrer vos mouvements, qui doivent être au format `(i,j)` où `i` est la ligne et `j` est la colonne de la cellule. Le jeu vous guidera à travers les mouvements possibles que vous pouvez faire.

## Conclusion
Ce jeu est une excellente façon d'apprendre et de pratiquer la programmation en Assembly 8086. Il démontre l'utilisation de divers concepts de programmation tels que les macros, les boucles et les tableaux. Profitez du jeu !

## Contact
Pour toute question ou commentaire, veuillez contacter notre équipe à l'Université USTHB, Info Ing L2. Nous apprécions votre intérêt pour notre jeu et attendons avec impatience de vos nouvelles.

**Remarque :** Ce document est rédigé en français. Si vous avez besoin d'une version en anglais, veuillez nous le faire savoir et nous serons heureux de vous la fournir. Profitez du jeu !

## Avertissement
Ce document est fourni "tel quel", sans garantie d'aucune sorte, expresse ou implicite, y compris mais sans s'y limiter, les garanties de qualité marchande, d'adéquation à un usage particulier et de non-violation. En aucun cas, les auteurs ou les détenteurs de droits d'auteur ne seront responsables de toute réclamation, dommages ou autre responsabilité, que ce soit dans le cadre d'une action contractuelle, délictuelle ou autre, découlant de, hors de ou en relation avec le logiciel ou l'utilisation ou d'autres transactions dans le logiciel.

## Licence
Ce projet est sous licence selon les termes de la licence MIT. Pour plus d'informations, veuillez vous référer au fichier [LICENSE](LICENSE) qui aurait dû être fourni avec ce logiciel. La licence MIT est simple et facile à comprendre et elle impose presque aucune restriction sur ce que vous pouvez faire avec ce logiciel.

## Remerciements
Nous tenons à exprimer notre plus profonde gratitude à tous ceux qui nous ont donné la possibilité de réaliser ce projet. Une gratitude particulière que nous donnons à notre Université USTHB, dont la contribution en suggestions stimulantes et encouragements, nous a aidé à coordonner notre projet surtout dans la rédaction de ce rapport.

## Auteurs
- Étudiant 1
- Étudiant 2
- Étudiant 3
- Étudiant 4
- Étudiant 5
- Étudiant 6

## Version
1.0.0

## Date
20 mai 2024
