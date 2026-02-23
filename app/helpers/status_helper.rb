module StatusHelper
  def status_badge(status)
    classes = case status.to_s
    when "up"
      "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300"
    when "down"
      "bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-300"
    when "degraded"
      "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300"
    end

    tag.span status.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end

  def severity_badge(severity)
    classes = case severity.to_s
    when "critical"
      "bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-300"
    when "major"
      "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300"
    when "minor"
      "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300"
    end

    tag.span severity.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end

  def incident_status_badge(status)
    classes = case status.to_s
    when "investigating"
      "bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-300"
    when "identified"
      "bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300"
    when "monitoring"
      "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
    when "resolved"
      "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300"
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
