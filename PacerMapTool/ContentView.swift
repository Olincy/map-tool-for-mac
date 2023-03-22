//
//  ContentView.swift
//  PacerMapTool
//
//  Created by lincy on 2023/3/22.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    typealias NSViewType = MKMapView
    @Binding var selectedFilePath:String?
    

    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    
    func updateNSView(_ mapView: MKMapView, context: Context) {
        
        if let filePath = selectedFilePath {
            do {
                let fileContents = try String(contentsOfFile: filePath)
                
                // 将文件数据按行拆分成数组
                let lines = fileContents.components(separatedBy: .newlines)
                
                // 创建路线数组，用于绘制地图路线
                var routePoints = [CLLocationCoordinate2D]()
                
                // 遍历文件数据的每一行，解析出经纬度信息，并将其加入路线数组
                // location格式："[timestamp] l [lat] [lng]..."
                for line in lines {
                    if (line.contains(" l ")) {
                        let components = line.components(separatedBy: " ")
                        if components.count > 4,
                            let latitude = Double(components[2]),
                            let longitude = Double(components[3]) {
                            let point = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            routePoints.append(point)
                        }
                    }
                    
                }
                
                // 使用路线数组绘制地图路线
                let route = MKPolyline(coordinates: routePoints, count: routePoints.count)
                mapView.addOverlay(route)
                
                // 调整路线可见区域
                mapView.setVisibleMapRect(route.boundingMapRect, animated: true)
                
            } catch {
                print(error)
            }
        }
    }
    
    // 实现MKMapViewDelegate协议方法，用于绘制路线
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct ContentView: View {
    @State var filePath: String?
    var body: some View {
        VStack {
            MapView(selectedFilePath:$filePath)
            HStack() {
                Button("选择") {
                    // 创建文件选择器
                    let dialog = NSOpenPanel()
                    dialog.title = "Select a file"
                    dialog.showsResizeIndicator = true
                    dialog.showsHiddenFiles = false
                    dialog.canChooseFiles = true
                    dialog.canChooseDirectories = false
                    dialog.allowsMultipleSelection = false
                    
                    // 显示文件选择器
                    if dialog.runModal() == NSApplication.ModalResponse.OK {
                        // 获取所选文件的路径
                        guard let selectedFileURL = dialog.url else {
                            return
                        }
                        filePath = selectedFileURL.path
                    }
                }.padding(.leading,10).frame(height: 30)
                Text(filePath ?? "文件路径")
            }.frame(height: 60).frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
