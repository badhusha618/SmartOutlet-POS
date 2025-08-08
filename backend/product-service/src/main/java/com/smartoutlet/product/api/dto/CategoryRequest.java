package com.smartoutlet.product.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Category creation and update request")
public class CategoryRequest {
    
    @Schema(description = "Category name", example = "Beverages")
    @NotBlank(message = "Category name is required")
    @Size(max = 100, message = "Category name cannot exceed 100 characters")
    private String name;
    
    @Schema(description = "Category description", example = "All types of drinks and beverages")
    private String description;
    
    @Schema(description = "Parent category ID", example = "1")
    private Long parentId;
    
    @Schema(description = "Category active status", example = "true")
    private Boolean isActive = true;
    
    @Schema(description = "Category sort order", example = "1")
    private Integer sortOrder = 0;
}