import UIKit
import CoreData

public struct SongData {
    let title: String
    let artist: String
    let url: URL?
    let artwork: UIImage?
}

public class SongFuncs
{
    public func saveSongToCoreData(songData: SongData) {
        let context = (UIApplication.shared.delegate as! AppDelegate).musicPersistentContainer.viewContext
        let song = SongEntity(context: context)
        
        song.title = songData.title
        song.artist = songData.artist
        song.url = songData.url?.absoluteString
        if let artwork = songData.artwork {
            song.imageData = artwork.pngData()
        }

        do {
            try context.save()
            print("Song saved successfully!")
        } catch {
            print("Failed to save song: \(error)")
        }
    }
    
    public func fetchSongsFromCoreData() -> [SongData] {
        let context = (UIApplication.shared.delegate as! AppDelegate).musicPersistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()

        do {
            let songs = try context.fetch(fetchRequest)
            return songs.map { song in
                // Construct and return SongData for each fetched song
                return SongData(
                    title: song.title ?? "Unknown",
                    artist: song.artist ?? "Unknown",
                    url: URL(string: song.url ?? "") ?? nil,
                    artwork: song.imageData != nil ? UIImage(data: song.imageData!) : nil
                )
            }
        } catch {
            print("Failed to fetch songs: \(error.localizedDescription)")
            return []
        }
    }

    public func deleteAllSongs() {
        let context = (UIApplication.shared.delegate as! AppDelegate).musicPersistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        
        do {
            let songs = try context.fetch(fetchRequest)
            for song in songs {
                context.delete(song)
            }
            try context.save()
        } catch {
            print("Failed to delete songs: \(error)")
        }
    }
}
