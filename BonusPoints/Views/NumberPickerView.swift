//
//  NumberPickerView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 15.12.22.
//


import SwiftUI


struct Number_Picker_View: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataHandler: AppDataHandler
    
    @Environment(\.dismiss) private var dismiss
    
    @State var task: TaskStruct
    
    func setTo(x: Int) {
//        dataHandler.tasks.setPoint(taskListNum: taskListNum, taskNum: taskNum, count: x)
//        dataHandler.updateTaskDone(taskId: task.id, count: x)
        dismiss()
    }
    
    var body: some View {
        VStack{
            Text("Set Score of \(task.name)")
                .bold()
                .padding(20)
                .font(.title)
            
            VStack(spacing: 0){
                HStack(spacing: 0){
                    Button(action: {setTo(x: 1)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("1")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 2)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("2")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 3)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("3")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                }
                
                Divider()
                
                HStack(spacing: 0){
                    Button(action: {setTo(x: 4)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("4")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 5)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("5")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 6)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("6")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    Button(action: {setTo(x: 7)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("7")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 8)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("8")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {setTo(x: 9)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("9")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    HStack{
                        Spacer()
                        VStack {
                            Spacer()
                            Text("")
                            Spacer()
                        }
                        Spacer()
                    }
                    Divider()
                    Button(action: {setTo(x: 0)}) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("0")
                            Spacer()
                        }
                        Spacer()
                    }.padding()
                    Divider()
                    Button(action: {
                        dismiss()
                    }) {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("Done")
                                .foregroundColor(.blue)
                                .font(.title)
                            Spacer()
                        }
                        Spacer()
                    }.padding(0)
                }
            }.font(.largeTitle)
                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            
        }//.buttonStyle(PlainButtonStyle())
        .buttonStyle(.borderless)
    }
}

struct Number_Picker_View_Previews: PreviewProvider {
    static var previews: some View {
        Number_Picker_View(task: TaskStruct(name: "", id: "", listId: "", pointsToAdd: 0, howManyTimesDidAllUsers: 0, counter: .now, orderWeight: 0))
            .environmentObject(AppDataHandler())
    }
}
