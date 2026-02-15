module StatusHelper
  def status_badge(status)
    classes = case status.to_s
    when "up"
      "bg-green-100 text-green-800"
    when "down"
      "bg-red-100 text-red-800"
    when "degraded"
      "bg-yellow-100 text-yellow-800"
    else
      "bg-gray-100 text-gray-800"
    end

    tag.span status.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end

  def severity_badge(severity)
    classes = case severity.to_s
    when "critical"
      "bg-red-100 text-red-800"
    when "major"
      "bg-orange-100 text-orange-800"
    when "minor"
      "bg-yellow-100 text-yellow-800"
    else
      "bg-gray-100 text-gray-800"
    end

    tag.span severity.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end

  def incident_status_badge(status)
    classes = case status.to_s
    when "investigating"
      "bg-red-100 text-red-800"
    when "identified"
      "bg-orange-100 text-orange-800"
    when "monitoring"
      "bg-blue-100 text-blue-800"
    when "resolved"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end

    tag.span status.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end

  def overall_status_class(status)
    case status.to_sym
    when :operational
      "bg-green-500"
    when :degraded
      "bg-yellow-500"
    when :partial_outage
      "bg-orange-500"
    when :major_outage
      "bg-red-500"
    else
      "bg-gray-500"
    end
  end

  def overall_status_text(status)
    case status.to_sym
    when :operational
      "All Systems Operational"
    when :degraded
      "Degraded Performance"
    when :partial_outage
      "Partial Outage"
    when :major_outage
      "Major Outage"
    else
      "Unknown"
    end
  end
end
