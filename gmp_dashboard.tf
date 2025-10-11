# Google Cloud Monitoring 대시보드 설정
# GMP 메트릭을 위한 통합 대시보드

resource "google_monitoring_dashboard" "gmp_dashboard" {
  count = var.gmp_enabled ? 1 : 0
  
  project = var.gcp_project_id
  dashboard_json = jsonencode({
    displayName = "PitterPetter GMP Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        # CPU 사용률
        {
          width = 6
          height = 4
          widget = {
            title = "CPU 사용률 (Container)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"k8s_container\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/container/cpu/core_usage_time\""
                      aggregation = {
                        alignmentPeriod = "60s"
                        perSeriesAligner = "ALIGN_RATE"
                        crossSeriesReducer = "REDUCE_MEAN"
                        groupByFields = ["resource.labels.container_name"]
                      }
                    }
                  }
                  plotType = "LINE"
                  targetAxis = "Y1"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "CPU 사용률 (cores)"
                scale = "LINEAR"
              }
            }
          }
        },
        # 메모리 사용률
        {
          width = 6
          height = 4
          xPos = 6
          widget = {
            title = "메모리 사용률 (Container)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"k8s_container\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/container/memory/used_bytes\""
                      aggregation = {
                        alignmentPeriod = "60s"
                        perSeriesAligner = "ALIGN_MEAN"
                        crossSeriesReducer = "REDUCE_MEAN"
                        groupByFields = ["resource.labels.container_name"]
                      }
                    }
                  }
                  plotType = "LINE"
                  targetAxis = "Y1"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "메모리 사용량 (bytes)"
                scale = "LINEAR"
              }
            }
          }
        },
        # 네트워크 수신
        {
          width = 6
          height = 4
          yPos = 4
          widget = {
            title = "네트워크 수신 (Pod)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"k8s_pod\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/pod/network/received_bytes_count\""
                      aggregation = {
                        alignmentPeriod = "60s"
                        perSeriesAligner = "ALIGN_RATE"
                        crossSeriesReducer = "REDUCE_MEAN"
                        groupByFields = ["resource.labels.pod_name"]
                      }
                    }
                  }
                  plotType = "LINE"
                  targetAxis = "Y1"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "수신 (bytes/sec)"
                scale = "LINEAR"
              }
            }
          }
        },
        # 네트워크 송신
        {
          width = 6
          height = 4
          xPos = 6
          yPos = 4
          widget = {
            title = "네트워크 송신 (Pod)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"k8s_pod\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/pod/network/sent_bytes_count\""
                      aggregation = {
                        alignmentPeriod = "60s"
                        perSeriesAligner = "ALIGN_RATE"
                        crossSeriesReducer = "REDUCE_MEAN"
                        groupByFields = ["resource.labels.pod_name"]
                      }
                    }
                  }
                  plotType = "LINE"
                  targetAxis = "Y1"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "송신 (bytes/sec)"
                scale = "LINEAR"
              }
            }
          }
        },
        # Pod 재시작 횟수
        {
          width = 12
          height = 4
          yPos = 8
          widget = {
            title = "Container 재시작 횟수"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"k8s_container\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/container/restart_count\""
                      aggregation = {
                        alignmentPeriod = "60s"
                        perSeriesAligner = "ALIGN_DELTA"
                        crossSeriesReducer = "REDUCE_SUM"
                        groupByFields = ["resource.labels.container_name"]
                      }
                    }
                  }
                  plotType = "LINE"
                  targetAxis = "Y1"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "재시작 횟수"
                scale = "LINEAR"
              }
            }
          }
        }
      ]
    }
  })
}
