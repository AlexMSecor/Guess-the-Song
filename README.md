# Guess the Song

## Introduction
Guess the Song is an iOS app that plays a random section of a random song, for the specified duration (1 - 5 seconds). The user must select the correct song from a list of their imported music. However, if the user surpasses 3 incorrect guesses, it is game over! It came from the idea that I could correctly guess the music in my iPhone's library in 1 second. This project was challenging but very rewarding to complete.

### The Main Page
<p align="center">
  <img src="https://github.com/user-attachments/assets/6928a061-907d-4673-bec8-d573cd9ded67" width="30%" height="30%">
</p>

This image displays the main page of the application. Here the user will see my app's logo, along with the options to play the game or enter the settings. The user will also be presented with emoji music notes and question marks that vertically fall in the background. (I had a lot of fun designing the logo and the background of the main page, and I am very happy with how it turned out.)

### The Settings Page
<p align="center">
  <img src="https://github.com/user-attachments/assets/00f20708-b6bb-425e-a1cf-679b3e5304f9" width="30%" height="30%">
</p>

This image shows the settings page. Here, the user can set the duration of the played portion of the song from 1 - 5 seconds. The user can also reset their high score. (Resetting the high score was somethig I added while testing, but I figured it was not worth deleting and had a place in the settings.) The user will be presented with an alert asking to confirm score resetting.

### The Game Screen
<p align="center">
  <img src="https://github.com/user-attachments/assets/932ac675-0f54-4d20-a983-c43a4c6b3cc2" width="30%" height="30%">
</p>

This image showcases the game screen. To play, the user will start by clicking the play button. At the beginning of every round, a new song and random starting point will be determined. When the user clicks the play button, the app will begin playing the song for the selected duration from the settings page. The user will need to navigate through the table view and select the correct song. Once they are ready, they will click the submit button and either increase their score 🔥 or receive a wrong guess strike ❌.

### A Selected Song
<p align="center">
  <img src="https://github.com/user-attachments/assets/afb5b6b4-bdc2-4ff4-9193-3aa376fe82a0" width="30%" height="30%">
</p>

This image highlights when a user selects a song from the table view. The app will dislay the album cover art, allowing the user to better confirm their guess. (This is something I had planned to include since the beginning, and I am very happy with how it turned out. I believe it also sorts out if multiple artists have the same song title. I did not need to include the artist names in the table view cell, just by the album cover art the user can confirm they have the correct song/artist.)

### The Game Over Alert
<p align="center">
  <img src="https://github.com/user-attachments/assets/b43b2f0a-f452-4534-ae79-31560b840ff9" width="30%" height="30%">
</p>

This image shows the game over alert. This alert will appear once the user has incorrectly guessed songs 3 times (signified by the ❌). These incorrect guesses do not reset every round. The game keeps the incorrect guesses tally until a new game is started. The user's streak is also in the top right of this photo (signified by the #🔥). The game over alert lists the correct song and artist, the user's final game score, and the user's high score.

### High Score
<p align="center">
  <img src="https://github.com/user-attachments/assets/250e01ba-3aae-46e3-a8f3-0c8b55c769df" width="30%" height="30%">
</p>

This final photo showcases what the user sees when they hit a new high score (the 🔥 will become a 🏆).

## Challenges
Songs downloaded using Apple Music are DRM protected, meaning the song "has restrictions on how it can be used, such as copying, editing, or sharing." Unfortunately, there is nothing I could do about this other than blocking the game from storing the DRM protected songs in the first place.

Songs from the albums can have singles. This duplicates the song within the table view (seen within the final photo - High Score). To combat this, when checking if the guess is correct, as long as the title and artist matches, the game will count it as a correct guess.

## Improvements
The ability to filter the table view music down to a specific artist would prevent the user from spending too much time scrolling.

## Final Thoughts
This game was an idea that I have had for a while, and I am very happy that I finally created it. I find it a lot of fun to play, so it made testing even easier on me. The logo was something that I created using Pixlr. A favorite part of mine when creating desktop/mobile applications is being able to work on both the front-end and back-end, so this project was really rewarding to work on and complete.
