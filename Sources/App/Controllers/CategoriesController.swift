
import Vapor



struct CategoriesController: RouteCollection {

    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")

        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.put(Category.parameter, use: updateHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        categoriesRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
    }

    func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }

    func updateHandler(_ req: Request) throws -> Future<Category> {
        return try flatMap(
            to: Category.self,
            req.parameters.next(Category.self),
            req.content.decode(Category.self)
        ) { category, updatedCategory in
            category.name = updatedCategory.name
            
            return category.save(on: req)
        }
    }

    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        
        return try req.parameters.next(Category.self)
            .flatMap(to: [Acronym].self) { category in
                try category.acronyms.query(on: req).all()
        }
    }
}
