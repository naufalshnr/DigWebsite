Rails.application.routes.draw do
  root "dig#index"
  post "dig/lookup", to: "dig#lookup"
  post "dig/clear", to: "dig#clear"
end
