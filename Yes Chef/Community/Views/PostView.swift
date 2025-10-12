//
//  PostView.swift
//  Yes Chef
//
//  Created by Jihoon Kim on 9/25/25.
//
import SwiftUI

let screen = UIScreen.main.bounds

struct PostView: View {
    var recipe: Recipe
    var poster: User?
    
    
    @State private var mediaItem: Int? = 0

    var body: some View {
        ScrollView{
            VStack(spacing: 6 ){
                HStack(spacing: 6 ){
                    
                    //Back Button
                    ZStack{
                        Image(systemName: "chevron.backward").font(Font.title2)
                    }
                    
                    //Divider().padding(.horizontal, 15).background(Color.clear)
                    //Title
                    Spacer()
                    Text(recipe.name).font(Font.largeTitle)
                    //Bookmark Button
                    //Divider().padding(.horizontal, 5)
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(Font.title2)
                    //... Button
                    Image(systemName: "ellipsis")
                        .font(Font.title2)
                        .frame(alignment: .trailing)
                    
                }
                .padding(.bottom, screen.width/50)
                
                HStack{
                    
                     //Poster Profile Pic
                    if let photoString = poster?.profilePhoto {
                        let profilePhoto = URL(string: photoString)
                        AsyncImage(url: profilePhoto) { phase in
                            if let image = phase.image{
                                image
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                            } else{
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 40, height: 40)
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 40, height: 40)
                    }
                     //Poster Username
                    if let username = poster?.username{
                        Text(username)
                    } else{
                        Text("Username")

                    }
                    Spacer()
                    
                    //Follow Button
                    Button(){
                        
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray3))
                                .frame(width: 80, height: 30)
                            Text("Follow").foregroundColor(Color.black)
                        }
                        
                    }
                     
                }
                
                //Recipe Pics
                
                ScrollView(.horizontal){
                    HStack{
                        ForEach(Array(recipe.media.enumerated()), id: \.offset){ index, media in
                            
                            AsyncImage(url: URL(string: media)) { phase in
                                if let image = phase.image{
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: screen.width/1.2, height: screen.height/2.5)
                                        .id(index)
                                        
                                } else{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray3))
                                        .frame(width: screen.width/1.2, height: screen.height/2.5)
                                        .id(index)
                                }
                            }
                            
                        }
                    }
                    .scrollTargetLayout()
                    //TODO scroll targeting needs iOS 17 adapt this so it doesn't cause trouble
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $mediaItem)
                
                //Scroll Dot Indicator
                HStack(spacing: 1){
                    ForEach(Array(recipe.media.enumerated()), id: \.offset){ index, media in
                        if let mediaNum = mediaItem{
                            if index == mediaNum{
                                //Text("\(mediaNum)")
                                Text("•")
                                    .font(Font.largeTitle)
                                    .foregroundColor(Color.black)
                            }
                            else{
                                Text("•")
                                    .font(Font.largeTitle)
                                    .foregroundColor(Color.gray)

                            }
                        }
                        
                    }
                }
                
                //Recipe Description
                Text(recipe.description).font(Font.body)
                
                HStack(){
                    let space = screen.width/75
                     //Difficulty Icon
                    Image(systemName: "flame.fill")
                    Text(LocalizedStringKey(recipe.difficulty.id.prefix(1).uppercased() + recipe.difficulty.id.dropFirst()))
                        .padding(.trailing, space)
                        
                     //Time+Icon
                    Image(systemName: "clock")
                    Text("\(recipe.prepTime) minutes")
                        .padding(.trailing, space)
                    
                     //Serving Size
                    Image(systemName: "person.fill")
                    
                    //TODO recipe has no serving size variable so this will have to be adapted
                    Text("Serves 1 person").lineLimit(1)
                    Spacer()


                }.padding(.vertical,10)
                
                //Ingredients
                VStack( alignment: .leading, spacing: 2){
                    Text("Ingredients").font(Font.title).padding(.vertical, screen.height/100)
                    ForEach (recipe.ingredients, id: \.self){ each in
                        BulletPoint(text: each, type: 1, num: 0).frame(maxHeight: 25)
                    }
                    
                    Text("Instructions")
                        .font(Font.title)
                        .padding(.vertical, screen.height/100)
                    //Instruction Steps
                    ForEach (Array(recipe.steps.enumerated()), id: \.offset){ index, each in
                        BulletPoint(text: each, type: 2, num: index)
                    }
                }
                
                ScrollView(.horizontal){
                    HStack{
                        //Tags
                        ForEach(recipe.tags, id: \.self){ tag in
                            Text(tag)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray5))
                                )
                                .foregroundColor(.black)
                        }
                    }
                }.padding(.top, screen.height/50)
                
                
                
            }
            .padding(15)
            .padding(.bottom, 80)
        }
    }
}
    
struct BulletPoint: View {
    var text: String
    let type: Int
    var num: Int
    
    var body: some View {
        HStack{
            if(type == 1){
                Text("•").font(Font.largeTitle)
            } else if (type == 2){
                if num <= 9{
                    Text("0\(num)").font(Font.title2).padding(.trailing, screen.width/75)
                }
            }
            Text(text).font(Font.body)
                .padding(.bottom, screen.height/100)
            Spacer()
        }
    }
    
}

#Preview {
    let rec = Recipe(userId: "userid", recipeId: "recipeID", name: "Chaffle", ingredients: ["1 egg", "3 cups of flour","1 teaspoon butter"], allergens: [""], tags: ["american", "keto", "gluten free"], steps: ["Preheat a waffle iron to medium-high. Whisk the eggs in a large bowl until well beaten and smooth.","Coat the waffle iron with nonstick cooking spray, then ladle a heaping 1/4 cup of batter into each section.","Top each chaffle with a pat of butter and drizzle with maple syrup. "], description: "A chaffle is a low-carb, cheese-and-egg-based waffle that's taken the keto world by storm, thanks to its fluffy texture and crispy edges.", prepTime: 120, difficulty: .easy, servingSize: 1, media: ["https://www.themerchantbaker.com/wp-content/uploads/2019/10/Basic-Chaffles-REV-Total-3-480x480.jpg","https://thebestketorecipes.com/wp-content/uploads/2022/01/Easy-Basic-Chaffle-Recipe-Easy-Keto-Chaffle-5.jpg",""])
    PostView(recipe: rec)
}

