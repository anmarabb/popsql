case 
    when p.departure_date > current_date() then "Furue" 
    else "Present" 
end as future_departure_date,