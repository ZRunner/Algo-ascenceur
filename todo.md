# Liste des choses à faire :


### • ~~Gestion des couleurs pour la version terminale~~
Lorsque le jeu est joué dans un terminale (donc sans graphisme) chaque joueur doit avoir une couleur assignée. Il faut pouvoir prévoire une couleur différente par joueur.

### • ~~Configuration lisible dans un fichier .json~~
Il faut créer un fichier au format json pour y insérer les configurations des parties (celles qui ne sont pas demandées aux joueurs), puis intégrer la lecture de ce fichier dans la fonction `loadconfig`, à la place de la chaine de caractères actuelle.

### • ~~Introduction au jeu~~
Les utilisateurs doivent avoir une courte présentation du jeu au début de la partie, puis être en mesure de donner le nombre de joueurs (entre 1 et le nombre max du fichier de config).

### • Fonction pour demander la carte à jouer à un joueur
Il faudra sans doute en argument le joueur, puis afficher le texte en couleur, demander la carte à jouer, vérifier qu'elle soit bien dans son paquet de cartes, et la retourner.

### • Fonction de gestion d'une manche
Distribution des cartes (fait), affichage des cartes pour chaque joueur, demande des paris, puis pour chaque tour demande à chacun des joueurs de jouer une carte, comparaison des valeurs (gestion des 4 couleurs), détermination du gagnant, ajout d'un point dans le nombre de plis gagnés. On retourne à la fin la liste des joueurs avec leur nombre de points mis à jour.

### • Gestion des manches
Dans la procédure principale, nous aurons besoin d'appeller la fonction de gestion d'une manche à chaque nouvelle manche, et de gérer le N° de manche, le type de phase (ascendante ou descendante), le nombre de points par joueur, et l'appel de la procédure finale.

### • Procédure finale
Prend en arguments la liste des joueurs pour déterminer le gagnant en fonction des points totaux, puis affiche le gagnant et éventuellement quelques stats bonus (nombre de plis par joueur, moyenne des paris etc).

### • Affichage des cartes dans le terminal
Si jamais les joueurs veulent jouer dans le terminal, il faut trouver un moyen simple et intuitif d'afficher les cartes d'un joueur (qui peuvent être entre 1 et 26 selon les parties et le nombre de joueurs).

### • Tests sur une interface graphique
Avant de se lancer à la "traduction" du jeu en dessins, il va falloir exécuter quelques tests sur le package `glib2D` : affichage d'éléments graphiques, affichage d'images externes, affichage de texte, détection de clics, champ de texte...

### • Faire le rapport (En cours(A mince on est pas à l'école ...))
Présentation du sujet, "mode d'emploi" du programme, explications du code, et résumé du projet selon chacun de nous. Le tout en LaTeX bien évidemment.
